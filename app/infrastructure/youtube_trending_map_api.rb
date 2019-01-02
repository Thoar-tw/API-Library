# frozen_string_literal: true

require 'http'

module YouTubeTrendingMap
  module Gateway
    # Infrastructure to call CodePraise API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def get_hot_videos(region_code, category_id)
        @request.get_hot_videos(region_code, category_id)
      end

      def get_global_top_videos(category_id)
        @request.get_global_top_videos(category_id)
      end

      def get_continent_top_videos(continent_name, category_id)
        @request.get_continent_top_videos(continent_name, category_id)
      end

      def get_country_top_videos(region_code, category_id)
        @request.get_country_top_videos(region_code, category_id)
      end

      def list_favorite_videos(list)
        @request.list_favorite_videos(list)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = config.API_HOST + '/api/v1'
        end

        def get_root # rubocop:disable Naming/AccessorMethodName
          call_api('get')
        end

        def get_hot_videos(region_code, category_id)
          call_api('post', ['hot_videos', region_code, category_id])
        end

        def get_global_top_videos(category_id)
          call_api('post', ['top_videos', 'global', category_id])
        end

        def get_continent_top_videos(category_id)
          call_api('post', ['top_videos', 'continent', continent_name, category_id])
        end

        def get_country_top_videos(region_code, category_id)
          call_api('post', ['top_videos', 'country', region_code, category_id])
        end

        def list_favorite_videos(list)
          call_api('get', ['favorite_videos'],
                   'list' => Value::VideosListRequest.to_encoded(list))
        end

        private

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
                .yield_self { |str| str ? '?' + str : '' }
        end

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_str(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
              .yield_self { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        NotFound = Class.new(StandardError)

        SUCCESS_STATUS = (200..299).freeze

        def success?
          SUCCESS_STATUS.include? code
        end

        def failure?
          !success?
        end

        def ok?
          code == 200
        end

        def added?
          code == 201
        end

        def processing?
          code == 202
        end

        def message
          JSON.parse(payload)['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
