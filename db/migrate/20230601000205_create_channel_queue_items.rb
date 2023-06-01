class CreateChannelQueueItems < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_queue_items do |t|

      t.integer :video_id
      t.integer :channel_id
      t.timestamp :start_time
      t.timestamp :finish_time

      t.timestamps
    end
  end
end
