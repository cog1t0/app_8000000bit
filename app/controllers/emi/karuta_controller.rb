require "digest"

module Emi
  class KarutaController < ApplicationController
    CODE_FILES = { "app.js" => "text/javascript", "match.js" => "text/javascript", "style.css" => "text/css" }.freeze
    PRIVATE_FILES = %w[topics.js card-images.js reading-audio.js].freeze

    before_action :private_headers
    before_action :authenticate_player
    before_action :same_origin_script, only: :file
    # Rails rejects non-XHR scripts by default; validate Fetch Metadata instead.
    skip_after_action :verify_same_origin_request, only: :file

    def index
      unless PRIVATE_FILES.all? { |name| private_directory.join(name).file? }
        render plain: "かるたは じゅんびちゅうです。", status: :service_unavailable
        return
      end
      html = Rails.root.join("lib/emi_karuta/index.html").binread.sub("KARUTA_CSRF_TOKEN", form_authenticity_token)
      send_data html, type: "text/html; charset=utf-8", disposition: "inline"
    end

    def online
      token = params[:ticket]
      command = params[:command]
      return head :bad_request unless token.is_a?(String) && token.match?(/\A[0-9a-f]{32}\z/)
      return head :bad_request unless %w[join poll ready pick leave].include?(command)
      name = params[:nickname]
      if command == "join"
        return head :bad_request unless name.is_a?(String) && name.strip.length.between?(1, 16)
      end
      if command == "pick"
        return head :bad_request unless (1..46).cover?(params[:card]) && params[:round].is_a?(Integer)
      end
      render json: Emi::KarutaLobby.new.update(token, command, nickname: command == "join" ? name.strip : nil, card: params[:card], round: params[:round])
    end

    def file
      name = params[:name]
      path = case name
      when "app.js" then Rails.root.join("lib/emi_karuta/app.js")
      when "match.js" then Rails.root.join("lib/emi_karuta/match.js")
      when "style.css" then Rails.root.join("lib/emi_karuta/style.css")
      when "topics.js" then private_directory.join("topics.js")
      when "card-images.js" then private_directory.join("card-images.js")
      when "reading-audio.js" then private_directory.join("reading-audio.js")
      end
      return head :not_found unless path

      type = CODE_FILES.fetch(name, "text/javascript")
      return head :not_found unless path.file?

      # Send bytes through this authenticated response, never redirect to a public asset.
      send_data path.binread, type: "#{type}; charset=utf-8", disposition: "inline"
    end

    private

    def same_origin_script
      if params[:name].to_s.end_with?(".js") && request.headers["Sec-Fetch-Site"] != "same-origin"
        head :forbidden
      end
    end

    def private_directory
      Rails.root.join("storage/emi_karuta")
    end

    def private_headers
      response.headers["Cache-Control"] = "private, no-store"
      response.headers["X-Robots-Tag"] = "noindex, nofollow"
      response.headers["X-Content-Type-Options"] = "nosniff"
      response.headers["Cross-Origin-Resource-Policy"] = "same-origin"
      response.headers["Referrer-Policy"] = "no-referrer"
    end

    def authenticate_player
      username = ENV["EMI_KARUTA_USERNAME"]
      password = ENV["EMI_KARUTA_PASSWORD"]
      if username.blank? || password.blank?
        render plain: "かるたは じゅんびちゅうです。", status: :service_unavailable
        return
      end

      authenticate_or_request_with_http_basic("Emi Karuta") do |given_user, given_password|
        ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(given_user.to_s), Digest::SHA256.hexdigest(username)) &
          ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(given_password.to_s), Digest::SHA256.hexdigest(password))
      end
    end
  end
end
