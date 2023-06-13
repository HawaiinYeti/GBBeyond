class VideoSyncJob < ApplicationJob
  include SuckerPunch::Job

  def perform(start_date = nil)
    gb_client = Api::GB.new

    start_date = if start_date.nil? && Video.all.size.zero?
                  '2008-01-01'.to_datetime
                 elsif start_date.nil? && Video.all.size.nonzero?
                   Video.maximum(:publish_date).to_datetime - 1.day
                 else
                   start_date.to_datetime
                 end
    field_list = 'id,guid,name,deck,image,video_show,low_url,high_url,hd_url,video_categories,site_detail_url,youtube_id,length_seconds,premium,publish_date'
    finish_date = Time.zone.now.to_datetime
    fields = {
      field_list: field_list,
      filter: "publish_date:#{start_date}|#{finish_date}",
      sort: 'publish_date:asc'
    }

    videos = [gb_client.get('videos', fields)[:results][:video]].flatten
    ActiveRecord::Base.connection_pool.with_connection do
      while videos.present?
        videos.each do |video|
          atts = {
            api_id: video[:id],
            api_guid: video[:guid],
            name: video[:name],
            deck: video[:deck],
            image_urls: video[:image],
            show_id: video.dig(:video_show, :id),
            category_id: video.dig(:video_categories, :id),
            site_url: video[:site_detail_url],
            youtube_id: video[:youtube_id],
            length: video[:length_seconds],
            premium: (video[:premium] || false),
            publish_date: video[:publish_date].in_time_zone,
            video_urls: {
              'hd' => video[:hd_url],
              'low' => video[:low_url],
              'high' => video[:high_url]
            },
          }

          Video.find_or_initialize_by(api_id: atts[:api_id]).update(atts)

          if video[:video_show].present?
            show_atts = {
              api_id: video.dig(:video_show, :id),
              title: video.dig(:video_show, :title),
              image_urls: video.dig(:video_show, :image),
              logo_urls: video.dig(:video_show, :logo),
              site_url: video.dig(:video_show, :site_detail_url),
            }

            Show.find_or_initialize_by(api_id: show_atts[:api_id]).update(show_atts)
          end
        end

        next_page = gb_client.next_page
        videos = if next_page[:results].empty?
          []
        else
          sleep(20)
          next_page[:results][:video]
        end
      end
    end
  end

end
