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
          video_urls: {
            'hd' => video[:hd_url]
            'low' => video[:low_url],
            'high' => video[:high_url]
          }
        }

        persisted_video = Video.find_or_initialize_by(api_id: atts[:api_id])
        persisted_video.update(atts)
        sleep(0.25)
      end

      videos = gb_client.next_page[:results][:video]
    end
  end

end
