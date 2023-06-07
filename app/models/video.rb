class Video < ApplicationRecord
  belongs_to :show, optional: true
  scope :random, -> { order('RANDOM()') }

  def get_url(quality = nil)
    if !(video_urls['hd'] || video_urls['high'] || video_urls['low']).start_with?('https://video.giantbomb.com')
      update_urls
    end

    if quality
      url = video_urls["#{quality}"]
      if url.nil?
        if quality == 'hd'
          url = video_urls['high'] || video_urls['low']
        elsif quality == 'high'
          url = video_urls['low']
        elsif quality == 'low'
          url = video_urls['high'] || video_urls['hd']
        end
      end
    else
      url = video_urls['hd'] || video_urls['high'] || video_urls['low']
    end

    if url.start_with?('https://video.giantbomb.com')
      url += "?api_key=#{Setting.gb_api_key}"
    end

    url
  end

  def update_urls
    if !(video_urls['hd'] || video_urls['high'] || video_urls['low']).start_with?('https://video.giantbomb.com')
      api_video = Api::GB.new.get("video/#{api_id}",
                              field_list: 'low_url,high_url,hd_url')[:results]
      provided_urls = [
        ('hd' if api_video[:hd_url].present?),
        ('low' if api_video[:low_url].present?),
        ('high' if api_video[:high_url].present?),
      ].compact

      provided_urls.each do |qual|
        video_urls[qual] =
          HTTParty.head(api_video["#{qual}_url".to_sym]).request.last_uri.to_s
      end

      save
    end
  end
end
