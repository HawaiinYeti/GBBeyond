class QueueJob
  include SuckerPunch::Job

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Channel.all.each do |channel|
        if channel.channel_queue_items.size.zero? ||
          channel.current_queue_item.nil? ||
          channel.current_queue_item.finish_time <= 5.minutes.since
          channel.add_to_queue(Video.random.first)
        end
        channel.finished_queue_items.delete_all
      end
    end
  end
end
