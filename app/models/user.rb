class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :rides, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :reported_maintenances, class_name: 'Maintenance', foreign_key: 'reported_by_id', dependent: :destroy
  has_many :cleanings_performed, class_name: 'Cleaning', foreign_key: 'cleaned_by_id', dependent: :destroy

  validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  validates :phone, format: { with: /\A[\+]?[1-9]?[\d\s\-\(\)]{8,}\z/, 
                             message: "format invalide" }, allow_blank: true

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def display_name
    full_name.present? ? full_name : email
  end
end
