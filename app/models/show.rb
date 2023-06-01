class Show < ApplicationRecord
  has_many :videos, primary_key: :api_id
end
