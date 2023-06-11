class Show < ApplicationRecord
  has_many :videos, primary_key: :api_id

  def self.ransackable_attributes(auth_object = nil)
    super - %w[id api_guid created_at updated_at image_urls video_urls logo_urls
               site_url]
  end
end
