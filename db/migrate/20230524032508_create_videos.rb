class CreateVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :videos do |t|

      t.integer :api_id
      t.integer :api_guid
      t.string :name
      t.text :deck
      t.json :image_urls, default: {}
      t.integer :show_id
      t.json :video_urls, default: {}
      t.integer :category_id
      t.string :site_url
      t.string :youtube_id
      t.integer :length
      t.boolean :premium
      t.datetime :publish_date

      t.timestamps
    end
  end
end
