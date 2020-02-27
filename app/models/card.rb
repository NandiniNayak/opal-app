class Card < ApplicationRecord
  has_many :attendances
  belongs_to :profile
end
