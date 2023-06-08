class ChannelsChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "all_channels"
    ActionCable.server.broadcast "all_channels", {
      command: 'initial_channel_listing',
      data: Channel.order(name: :asc).channel_listing
    }
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
