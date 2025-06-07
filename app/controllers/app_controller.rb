require 'net/http'
require 'json'

class AppController < ApplicationController
  def index
  end

  def history
  end

  def search
    lat = params[:lat]
    lon = params[:lon]
    category = params[:category]

    url = case category
          when 'history'
            api_key = ENV.fetch('HISTORY_API_KEY', 'HISTORY_KEY')
            "https://history.example/api?lat=#{lat}&lon=#{lon}&apiKey=#{api_key}"
          when 'food'
            api_key = ENV.fetch('FOOD_API_KEY', 'FOOD_KEY')
            "https://food.example/api?lat=#{lat}&lon=#{lon}&apiKey=#{api_key}"
          else
            render json: { error: 'Unknown category' }, status: :bad_request and return
          end

    begin
      uri = URI.parse(url)
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
    rescue => e
      Rails.logger.error("API fetch error: #{e.message}")
      data = { 'items' => [] }
    end

    render json: data
  end
end
