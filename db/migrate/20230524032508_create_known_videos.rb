class CreateKnownVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :known_videos do |t|

      t.timestamps
    end
  end
end
