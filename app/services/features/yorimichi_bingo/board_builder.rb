module Features
  module YorimichiBingo
    class BoardBuilder
      DEFAULT_TITLE = "いつもとちがう30日".freeze
      DEFAULT_DURATION_DAYS = 30

      DEFAULT_ITEMS = [
        "いつもと違う道で帰る",
        "新しいパン屋さんに寄る",
        "図書館で雑誌を一冊めくる",
        "公園で深呼吸を3回する",
        "夜空の星を5つ探す",
        "知らない国の料理を食べる",
        "道端の花の名前を調べる",
        "手紙を書いてみる",
        "朝にラジオ体操する",
        "本屋で表紙買いする",
        "誰かに「ありがとう」を伝える",
        "水筒に好きな飲み物を入れる",
        "ポッドキャストを新しく聞く",
        "知らない音楽ジャンルを聴く",
        "おにぎりを握って外で食べる",
        "昔の写真を1枚見返す",
        "初めてのスーパーに寄る",
        "近くの神社にお参りする",
        "早起きして朝日を見る",
        "寝る前にストレッチする",
        "新しい香りのものを試す",
        "メモを1ページ自由に描く",
        "誰かに小さなおすそ分けをする",
        "水辺を10分眺める",
        "今日よかったことを3つ書く"
      ].freeze

      def initialize(title:, duration_days: DEFAULT_DURATION_DAYS)
        @title = title.presence || DEFAULT_TITLE
        @duration_days = normalize_duration(duration_days)
      end

      def call
        BingoCard.create!(
          title: @title,
          items: build_items,
          expires_at: @duration_days.days.from_now
        )
      end

      private

      def build_items
        DEFAULT_ITEMS.map.with_index(1) do |item_title, index|
          { "id" => index, "title" => item_title, "checked" => false, "checked_at" => nil }
        end
      end

      def normalize_duration(duration_days)
        days = duration_days.to_i
        return DEFAULT_DURATION_DAYS if days <= 0

        days
      end
    end
  end
end
