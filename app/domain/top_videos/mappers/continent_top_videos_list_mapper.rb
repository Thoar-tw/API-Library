# frozen_string_literal: true

module YouTubeTrendingMap
  module Mapper
    # Data structure of trending list queried from Youtube
    class ContinentTopVideosList
      include Mixins::TopVideosAggregator

      def initialize(continent, api_key, gateway_class = YouTubeTrendingMap::YoutubeAPI)
        @continent = continent
        @api_key = api_key
        @gateway_class = gateway_class
      end

      def get(category_id, max_results)
        videos_lists =
          get_lists_from_countries_in_(@continent, category_id, max_results)

        build_entity(aggregate(videos_lists))
      end

      def build_entity(data)
        Entity::ContinentTopVideosList.new(
          id: nil,
          count: data.length,
          belonging_continent: @continent,
          videos: data
        )
      end

      private

      def get_lists_from_countries_in_(continent, category_id, max_results)
        country_codes = ['tw', 'jp']
        # country_codes = country_codes_in_(continent)
        list = []
        country_codes.each do |country_code|
          list << Mapper::CountryTopVideosList
                  .new(@api_key, @gateway_class)
                  .get(country_code, category_id, max_results)
        end
        puts "get_lists_from_countries_in_" + continent
        puts list

        list
      end

      def country_codes_in_(continent)
        country_codes = []
        CONTINENT_COUNTRY_CODES[continent].each do |country_code, _|
          country_codes << country_code
        end

        country_codes
      end
    end
  end
end