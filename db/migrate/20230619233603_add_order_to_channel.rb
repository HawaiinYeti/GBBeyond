class AddOrderToChannel < ActiveRecord::Migration[7.0]
  def change
    add_column :channels, :position, :integer
  end
end
