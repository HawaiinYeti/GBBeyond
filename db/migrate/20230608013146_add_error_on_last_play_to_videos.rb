class AddErrorOnLastPlayToVideos < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :error_on_last_play, :boolean, default: false
    add_column :videos, :error_on_last_play_at, :datetime
  end
end
