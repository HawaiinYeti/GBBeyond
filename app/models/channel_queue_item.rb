class ChannelQueueItem < ApplicationRecord
  belongs_to :channel
  belongs_to :video

  # after_create :broadcast_to_player

  def broadcast_to_player
    ActionCable.server.broadcast "all_channels", {
      command: 'channel_update',
      data: { channel.id => channel.broadcast_object }
    }
  end

  def broadcast_object
    {
      queue_item: self,
      video: video,
      url: video&.get_url,
      skip_url: Rails.application.routes.url_helpers.
                skip_queue_item_channel_path(channel.id, queue_item_id: id),
    }
  end

  def current_time
    (Time.now - start_time).to_i
  end

  def skip
    next_items = channel.channel_queue_items.
                 where('start_time > ?', start_time).
                 order(start_time: :asc)

    next_items.each do |item|
      if item.start_time - video.length.seconds < Time.now
        start = Time.zone.now
        finish = start + item.video.length.seconds
      else
        start = item.start_time - video.length.seconds
        finish = item.finish_time - video.length.seconds
      end
      item.update(start_time: start, finish_time: finish)
    end
    destroy
    next_items.first&.broadcast_to_player
  end
end
