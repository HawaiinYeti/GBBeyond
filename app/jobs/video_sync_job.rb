class VideoSyncJob
  include SuckerPunch::Job

  def perform
    gb_client = Api::GB.new

    field_list = 'id,guid,name,deck,image,video_show,low_url,high_url,hd_url,video_categories,site_detail_url,youtube_id,length_seconds,premium'
    fields = {
      field_list: field_list
    }

    videos = gb_client.get('videos', fields)[:results][:video]
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
          premium: video[:premium]
        }

        persisted_video = Video.find_or_initialize_by(api_id: atts[:api_id])
        persisted_video.update(atts)
        check_video_urls(video, persisted_video)
        persisted_video.save

        if video[:video_show].present?
          show_atts = {
            api_id: video[:video_show][:id],
            title: video[:video_show][:title],
            image_urls: video[:video_show][:image],
            logo_urls: video[:video_show][:logo]
          }
          Show.find_or_initialize_by(api_id: show_atts[:api_id]).update(show_atts)
        end
        sleep(0.25)
      end

      videos = gb_client.next_page[:results][:video]
    end
  end

  def check_video_urls(video, persisted_video)
    provided_urls = [
      ('hd' if video[:hd_url].present?),
      ('low' if video[:low_url].present?),
      ('high' if video[:high_url].present?),
    ].compact

    provided_urls.each do |qual|
      next if persisted_video.video_urls[qual].to_s[0..35] ==
              'https://videos-cloudfront.jwpsrv.com'

      persisted_video.video_urls[qual] =
        HTTParty.head(video["#{qual}_url".to_sym]).request.last_uri.to_s
    end
  end
end
