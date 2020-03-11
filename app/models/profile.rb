class Profile < ApplicationRecord
  # belongs_to :course
  has_one :card, dependent: :destroy
  belongs_to :course
end
