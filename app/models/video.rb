class Video < ApplicationRecord
  belongs_to :show, optional: true
  scope :random, -> { order('RANDOM()') }
end
