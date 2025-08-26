class Ride < ApplicationRecord
  belongs_to :user
  belongs_to :stroller
end
