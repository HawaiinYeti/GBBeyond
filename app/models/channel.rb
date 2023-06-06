class Channel < ApplicationRecord
  has_many :channel_queue_items

  def current_queue_item
    channel_queue_items.where('start_time <= :time AND finish_time >= :time', time: Time.now).first
  end

  def finished_queue_items
    channel_queue_items.where('finish_time < ?', Time.now)
  end

  def upcoming_queue_items
    channel_queue_items.where('start_time > ?', Time.now)
  end

  def add_to_queue(video)
    start_time = (channel_queue_items.last&.finish_time || Time.now) + 1.second
    channel_queue_items.new(
        video: video,
        start_time: start_time,
        finish_time: start_time + video.length.seconds
    ).save
  end

  def self.channel_listing
    all.map do |channel|
      video = channel.current_queue_item.video
      {
        name: channel.name,
        current_queue_item: channel.current_queue_item,
        current_video: video,
        url: video.get_url
      }
    end
  end
end
