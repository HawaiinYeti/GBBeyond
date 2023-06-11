class Video < ApplicationRecord
  belongs_to :show, optional: true, primary_key: 'api_id'
  scope :random, -> { order('RANDOM()') }

  def self.ransackable_attributes(auth_object = nil)
    super - %w[api_guid created_at updated_at image_urls video_urls site_url
               youtube_id]
  end

  def get_url(quality = nil)
    if (video_urls['hd'] || video_urls['high'] || video_urls['low']).exclude?('giantbomb.com')
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
      qualities = Setting.quality_play_order.split(',')
      url = qualities.map { |q| video_urls[q] }.compact.first
    end

    if url.include?('giantbomb.com')
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

  def report_error
    update(error_on_last_play: true, error_on_last_play_at: Time.zone.now)
  end

  def length_str
    days = length / (3600 * 24)
    day_s = days > 1 ? 's' : ''
    "#{days.to_s + " day#{day_s}, " if days.positive?}#{(length / 3600) % 24}:#{"%02d" % ((length / 60) % 60)}:#{"%02d" % (length % 60)}"
  end

  def self.length_str
    days = sum(:length) / (3600 * 24)
    day_s = days > 1 ? 's' : ''
    "#{days.to_s + " day#{day_s}, " if days.positive?}#{(sum(:length) / 3600) % 24}:#{"%02d" % ((sum(:length) / 60) % 60)}:#{"%02d" % (sum(:length) % 60)}"
  end
end
