class CreateShows < ActiveRecord::Migration[7.0]
  def change
    create_table :shows do |t|

      t.integer :api_id
      t.string :title
      t.json :image_urls, default: {}
      t.json :logo_urls, default: {}
      t.string :site_url

      t.timestamps
    end
  end
end
