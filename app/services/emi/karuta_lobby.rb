require "pstore"

module Emi
  class KarutaLobby
    def initialize(path = Rails.root.join("storage/emi_matches.pstore"))
      @store = PStore.new(path.to_s, true)
    end

    def update(token, action, nickname: nil, round: nil, card: nil)
      now = Time.now.to_f
      @store.transaction do
        rooms = @store[:rooms] ||= []
        rooms.reject! { |room| room[:players].all? { |p| now - p[:seen] > 60 } }
        rooms.each do |room|
          room[:phase] = "closed" if room[:phase] != "finished" && room[:players].any? { |p| now - p[:seen] > 60 }
        end
        room = rooms.find { |r| r[:players].any? { |p| p[:token] == token } }
        if action == "join" && !room
          room = rooms.find { |r| r[:phase] == "waiting" }
          unless room
            room = { players: [], deck: (1..46).to_a.shuffle, pile: (1..46).to_a.shuffle, phase: "waiting", round: 1 }
            rooms << room
          end
          room[:players] << { token: token, name: nickname, seen: now, hand: [], ready: false }
          room[:phase] = "preparing" if room[:players].length == 2
        end
        next({ phase: "closed" }) unless room

        players = room[:players]
        seat = players.index { |p| p[:token] == token }
        player = players[seat]
        player[:seen] = now
        case action
        when "leave"
          room[:phase] = "closed"
        when "ready"
          if room[:phase] == "preparing"
            player[:ready] = true
            if players.all? { |p| p[:ready] }
              room[:phase] = "playing"
              room[:opens] = now + 2
            end
          end
        when "pick"
          pile = room[:pile]
          if room[:phase] == "playing" && room[:round] == round && now >= room[:opens] && pile.include?(card)
            other = players[1 - seat]
            wrong = card != pile.first
            if wrong && player[:hand].any?
              penalty = player[:hand].find { |id| id != 35 } || 35
              other[:hand] << player[:hand].delete(penalty)
            end
            room[:event] = { seat: seat, card: card, wrong: wrong }
            if pile.size == 2
              (wrong ? other : player)[:hand].concat(pile.shift(2))
              room[:phase] = "finished"
            elsif !wrong
              player[:hand] << pile.shift
              room[:round] += 1
              room[:opens] = now + 2
            end
          end
        end
        { phase: room[:phase], seat: seat, deck: room[:deck], round: room[:round], event: room[:event],
          target: room[:phase] == "playing" && now >= room[:opens] ? room[:pile].first : nil,
          players: players.map { |p| p.slice(:name, :hand, :ready) } }
      end
    end
  end
end
