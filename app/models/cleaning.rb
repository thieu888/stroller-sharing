class Cleaning < ApplicationRecord
  belongs_to :stroller
  belongs_to :cleaned_by, class_name: 'User'

  validates :cleaning_type, presence: true, inclusion: { 
    in: %w[quick full disinfection deep_clean] 
  }

  scope :recent, -> { where('cleaned_at >= ? OR (cleaned_at IS NULL AND created_at >= ?)', 1.week.ago, 1.week.ago) }
  scope :by_type, ->(type) { where(cleaning_type: type) }

  def cleaned_at_display
    cleaned_at || created_at
  end
end
