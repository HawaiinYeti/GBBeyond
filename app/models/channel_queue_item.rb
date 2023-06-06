class ChannelQueueItem < ApplicationRecord
  belongs_to :channel
  belongs_to :video

  after_create :broadcast_to_player

  def broadcast_to_player
    ActionCable.server.broadcast "all_channels", { message:
      {
        name: channel.name,
        queue_item: self,
        video: self.video
      }
    }
  end
end
