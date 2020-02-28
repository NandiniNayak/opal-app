class Card < ApplicationRecord
  has_many :attendances, dependent: :destroy
  belongs_to :profile
end
