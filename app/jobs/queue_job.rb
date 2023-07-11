class QueueJob < ApplicationJob

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      play_jw = Setting.play_jwplayer
      play_premium = Setting.premium

      Channel.all.each do |channel|
        update = false
        while (channel.channel_queue_items.maximum(:finish_time) || Time.now) <= (Setting.hours_to_enqueue).hours.since
          videos = channel.videos.
                  where(premium: [false, play_premium].uniq).
                  where.not(length: [nil, 0])
          if !play_jw
            videos = videos.where.not("video_urls ->> 'high' LIKE '%jwplayer%'"); nil
          end
          video = videos.random.first
          break if video.nil?

          channel.add_to_queue(video)
          update = true
        end

        channel.finished_queue_items.destroy_all
        channel.channel_queue_items.last.broadcast_to_player if update
      end
    end
  end
end
