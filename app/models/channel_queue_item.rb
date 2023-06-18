class ChannelQueueItem < ApplicationRecord
  belongs_to :channel
  belongs_to :video

  after_create :broadcast_to_player

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
      url: video&.get_url
    }
  end

  def current_time
    (Time.now - start_time).to_i
  end
end
