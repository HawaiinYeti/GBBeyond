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
    start_time = if (channel_queue_items.last.present? &&
                     channel_queue_items.last.finish_time < 5.minutes.ago) ||
                    channel_queue_items.size.zero?
      Time.zone.now
    else
      channel_queue_items.last.finish_time
    end
    channel_queue_items.new(
        video: video,
        start_time: start_time,
        finish_time: start_time + video.length.seconds
    ).save
  end

  def self.channel_listing
    all.group_by(&:id).transform_values { |x| x.first.broadcast_object }
  end

  def broadcast_object
    {
      channel: self,
      queue: channel_queue_items.order(start_time: :asc).map(&:broadcast_object)
    }
  end
end
