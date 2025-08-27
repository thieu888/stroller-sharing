class Maintenance < ApplicationRecord
  belongs_to :stroller
  belongs_to :reported_by, class_name: 'User'

  validates :issue_description, presence: true, length: { minimum: 10 }
  validates :status, inclusion: { 
    in: %w[pending in_progress completed] 
  }

  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
end
