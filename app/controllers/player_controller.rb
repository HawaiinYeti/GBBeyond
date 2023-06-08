class PlayerController < ApplicationController

  def error
    Video.find(params[:video_id]).report_error
    channel = Channel.find_by(params[:channel_id])
    channel.replace_queue_item(params[:queue_item_id])
    render json: { data: { channel.id => channel.broadcast_object } }
  end
end
