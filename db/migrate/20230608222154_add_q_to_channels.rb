class AddQToChannels < ActiveRecord::Migration[7.0]
  def change
    add_column :channels, :q, :jsonb, default: {}
  end
end
