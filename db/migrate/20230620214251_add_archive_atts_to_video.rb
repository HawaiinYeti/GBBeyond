class AddArchiveAttsToVideo < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :archived, :boolean, default: false
    add_column :videos, :archived_quality, :string, default: nil
    add_column :channels, :archive_videos, :boolean, default: false
  end
end
