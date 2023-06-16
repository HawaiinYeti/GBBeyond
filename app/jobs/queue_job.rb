class QueueJob < ApplicationJob

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Channel.all.each do |channel|
        if channel.channel_queue_items.size.zero? ||
          channel.current_queue_item.nil? ||
          channel.channel_queue_items.maximum(:finish_time) <= 5.minutes.since
          videos = channel.videos.
                  where(premium: [false, Setting.premium].uniq).
                  where.not(length: [nil, 0])
          if !Setting.play_jwplayer
            videos = videos.where.not("video_urls ->> 'high' LIKE '%jwplayer%'")
          end
          video = videos.random.first
          return if video.nil?

          channel.add_to_queue(video)
        end

        channel.finished_queue_items.each(&:delete)
      end
    end
  end
end
