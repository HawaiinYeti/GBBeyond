class Channel < ApplicationRecord
  has_many :channel_queue_items, dependent: :destroy
  acts_as_list

  after_create :run_queue_job
  after_update :check_queue

  def current_queue_item
    channel_queue_items.where('start_time <= :time AND finish_time >= :time', time: Time.now).first
  end

  def finished_queue_items
    channel_queue_items.where('finish_time < ?', Time.now)
  end

  def upcoming_queue_items
    channel_queue_items.where('start_time > ?', Time.now)
  end

  def queue_item_at(time)
    channel_queue_items.where('start_time <= :time AND finish_time >= :time', time: time).first
  end

  def add_to_queue(video, at_front = false)
    queue_items = channel_queue_items.order(start_time: :asc).to_a
    start_time = if (queue_items.present? &&
                     queue_items.last.finish_time < 5.minutes.ago) ||
                    queue_items.size.zero? ||
                    at_front
      Time.zone.now
    elsif queue_items.present?
      queue_items.last.finish_time
    end
    channel_queue_items.eager_load(:channel, :video).new(
        video: video,
        start_time: start_time,
        finish_time: start_time + video.length.seconds
    ).save

    if at_front
      queue_items.each_with_index do |item, i|
        next if i.zero?

        item.update(start_time: queue_items[i - 1].finish_time,
                    finish_time: queue_items[i - 1].finish_time + item.video.length.seconds)
      end
    end
  end

  def self.channel_listing
    all.group_by(&:id).transform_values { |x| x.first.broadcast_object }
  end

  def broadcast_object
    {
      channel: self,
      queue: channel_queue_items.eager_load(video: :show).order(start_time: :asc).map(&:broadcast_object)
    }
  end

  def replace_queue_item(queue_item_id)
    channel_queue_items.find(queue_item_id)&.delete
    add_to_queue(Video.random.first, true)
  end

  def get_random_video
    Video.ransack(q).result.random.first
  end

  def videos
    Video.ransack(q).result
  end

  def run_queue_job
    QueueJob.perform_later
  end

  def check_queue
    return unless saved_change_to_q?

    current_id = current_queue_item&.id if videos.include?(current_queue_item&.video)

    channel_queue_items.where.not(id: current_id).destroy_all
    run_queue_job
  end
end
