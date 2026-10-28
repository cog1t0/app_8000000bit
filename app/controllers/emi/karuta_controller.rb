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
      send_data Rails.root.join("lib/emi_karuta/index.html").binread, type: "text/html; charset=utf-8", disposition: "inline"
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
