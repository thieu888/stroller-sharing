class Maintenance < ApplicationRecord
  belongs_to :stroller
  belongs_to :reported_by, class_name: 'User'

  validates :description, presence: true, length: { minimum: 10 }
  validates :maintenance_type, presence: true, inclusion: { 
    in: %w[mechanical electrical battery wheels brakes other] 
  }
  validates :priority, presence: true, inclusion: { 
    in: %w[low medium high] 
  }
  validates :status, inclusion: { 
    in: %w[pending in_progress completed] 
  }

  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :high_priority, -> { where(priority: 'high') }
end
