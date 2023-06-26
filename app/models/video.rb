class Video < ApplicationRecord
  belongs_to :show, optional: true, primary_key: 'api_id'
  scope :random, -> { order('RANDOM()') }

  def self.ransackable_attributes(auth_object = nil)
    super - %w[api_guid created_at updated_at image_urls video_urls site_url
               youtube_id]
  end

  def get_url(quality = nil, request = nil, return_quality = false, return_archived = true)
    if archived && File.exist?(archive_fullpath) && return_archived
      return archive_url(request)
    elsif archived && !File.exist?(archive_fullpath)
      update(archived: false, archived_quality: nil)
    end

    if (video_urls['hd'] || video_urls['high'] || video_urls['low']).exclude?('giantbomb.com')
      update_urls
    end

    qualities = Setting.quality_play_order.split(',')
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
      url = qualities.map { |q| video_urls[q] }.compact.first
    end

    if url.include?('giantbomb.com')
      url += "?api_key=#{Setting.gb_api_key}"
    end

    if return_quality
      [url, qualities.find { |q| video_urls[q] == (url.gsub("?api_key=#{Setting.gb_api_key}", '')) }]
    else
      url
    end
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

  def archive_filename
    "#{api_id}.mp4"
  end

  def archive_path
    if show_id.present?
      File.join('public', 'archive', "#{show_id}")
    else
      File.join('public', 'archive')
    end
  end

  def archive_fullpath
    File.join(Rails.root, archive_path, archive_filename)
  end

  def archive_url(request = nil)
    (request&.protocol.to_s + request&.host_with_port.to_s) +
      if show_id.present?
        File.join('/archive', "#{show_id}", archive_filename)
      else
        File.join('/archive', archive_filename)
      end
  end

  def archive_video
    FileUtils.mkdir_p(archive_path)
    if archived && !File.exist?(archive_fullpath)
      update(archived: false, archived_quality: nil)
    end

    Setting.quality_play_order.split(',').each do |qual|
      url = get_url(qual, nil, true, false)

      # Use HTTParty to download the video. Resume the download if the existing filesize is less than the remote file
      # size. This is a workaround for the fact that HTTParty doesn't support resuming downloads.
      remote_size = HTTParty.head(url[0]).headers['content-length'].to_i
      if File.exist?(archive_fullpath)
        local_size = File.size(archive_fullpath)
        if local_size < remote_size
          puts "Resuming download of #{archive_filename} at #{local_size} bytes"
          File.open(archive_fullpath, 'ab') do |file|
            file.write HTTParty.get(url[0], headers: { 'Range' => "bytes=#{local_size}-" }).body
          end
        else
          update(archived: true, archived_quality: url[1])
          puts "Skipping download of #{archive_filename} because it already exists"
        end
      else
        puts "Downloading #{archive_filename}"
        File.open(archive_fullpath, 'wb') do |file|
          # stream the download to the file
          HTTParty.get(url[0], stream_body: true) do |fragment|
            file.write(fragment)
          end
        end
      end

      update(archived: true, archived_quality: url[1]) if remote_size == File.size(archive_fullpath)
      break
    end
  end
end
