class Cleaning < ApplicationRecord
  belongs_to :stroller
  belongs_to :cleaned_by, class_name: 'User'

  validates :cleaning_type, presence: true, inclusion: { 
    in: %w[quick full disinfection deep_clean] 
  }
  validates :cleaned_at, presence: true

  scope :recent, -> { where(cleaned_at: 1.week.ago..Time.current) }
  scope :by_type, ->(type) { where(cleaning_type: type) }
end
