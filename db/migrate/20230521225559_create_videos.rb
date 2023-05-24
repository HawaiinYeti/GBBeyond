class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|

      t.string :title
      t.string :url
      t.integer :playcount
      t.text :description

      t.timestamps
    end
  end
end
