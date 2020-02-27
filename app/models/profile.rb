class Profile < ApplicationRecord
  # belongs_to :course
  has_one :card
end
