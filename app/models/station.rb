class Station < ApplicationRecord
  has_many :strollers, dependent: :nullify

  validates :name, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :gps_lat, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :gps_lng, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
end
