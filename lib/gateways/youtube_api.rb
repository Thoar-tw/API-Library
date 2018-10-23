# frozen_string_literal: false

require 'net/http'
require 'http'
require 'json'

require_relative 'popular_list.rb'

module APILibrary
  # class to get Youtube data
  class YoutubeAPI
    module Errors
      class BadRequest < StandardError; end
      class NotFound < StandardError; end
      class Unauthorized < StandardError; end
    end

    HTTP_ERROR = {
      400 => Errors::BadRequest,
      401 => Errors::Unauthorized,
      404 => Errors::NotFound
    }.freeze

    def initialize(key, cache: {})
      @api_key = key
      @cache = cache
    end

    def popular_list(region_code)
      response = get_most_popular_videos_list(region_code)
      list_data = JSON.parse(response)
      PopularList.new(list_data)
    end

    private

    # Attach params to url path
    def youtube_api_path(params_array)
      path = 'https://www.googleapis.com/youtube/v3/videos?'
      params_array.each.with_index do |param, index|
        path += '&' unless index.zero?
        path += param
      end
      path
    end

    # Use http get to get data from Youtube
    def call_yt_url(url)
      result = HTTP.get(url)
      successful?(result) ? result : raise_error(result)
    end

    # Input region code of the country and output data of trending videos with json format
    def get_most_popular_videos_list(region_code)
      param_part = 'part=snippet,player,statistics'
      param_chart = 'chart=mostPopular'
      param_region_code = 'regionCode=' + region_code
      param_video_category_id = 'video_category_id=\'\''
      param_key = 'key=' + @api_key

      param_array = [param_part, param_chart, param_region_code, param_video_category_id, param_key]
      response = call_yt_url(youtube_api_path(param_array))
      response
    end

    def successful?(result)
      # HTTP_ERROR.key(result.code) ? false : true
      HTTP_ERROR.keys.include?(result.code) ? false : true
    end

    def raise_error(result)
      raise(HTTP_ERROR[result.code])
    end
  end
end