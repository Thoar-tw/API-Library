# frozen_string_literal: true

module YouTubeTrendingMap
  module Database
    # Object Relational Mapper for YoutubeVideo Entities
    class YoutubeVideoOrm < Sequel::Model(:youtube_videos)
      many_to_many  :popular_lists_within,
                    class: :'APILirary::Database::PopularListOrm',
                    join_table: :popular_list_videos,
                    left_key: :youtube_video_id, right_key: :popular_list_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(youtube_video_info)
        first(title: youtube_video_info[:title]) || create(youtube_video_info)
      end
    end
  end
end