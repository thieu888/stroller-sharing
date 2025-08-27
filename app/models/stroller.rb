class Stroller < ApplicationRecord
  belongs_to :station, optional: true
  has_many :rides, dependent: :restrict_with_error
  has_many :maintenances, dependent: :destroy
  has_many :cleanings, dependent: :destroy

  validates :qr_code, presence: true, uniqueness: true
  validates :battery_level, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :status, presence: true, inclusion: { in: %w[available in_use maintenance cleaning out_of_service] }
  validates :gps_lat, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_nil: true
  validates :gps_lng, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_nil: true

  before_validation :set_default_status

  scope :available, -> { where(status: 'available') }
  scope :in_use, -> { where(status: 'in_use') }
  scope :needing_maintenance, -> { where(status: 'maintenance') }
  scope :low_battery, -> { where('battery_level < ?', 20) }

  def battery_status
    return 'unknown' if battery_level.nil?
    case battery_level
    when 0..20
      'low'
    when 21..50
      'medium'
    else
      'high'
    end
  end

  def can_be_used?
    status == 'available' && (battery_level.nil? || battery_level > 10)
  end

  def last_cleaning
    cleanings.order(cleaned_at: :desc, created_at: :desc).first
  end

  def pending_maintenances
    maintenances.where(status: 'pending')
  end

  def needs_cleaning?
    last_clean = last_cleaning
    return true if last_clean.nil?
    
    cleaned_date = last_clean.cleaned_at || last_clean.created_at
    cleaned_date < 1.week.ago
  end

  private

  def set_default_status
    self.status ||= 'available'
  end
end
