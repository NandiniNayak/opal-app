class Card < ApplicationRecord
  belongs_to :profile
  self.primary_key = 'opal_number'
  has_many :attendances, primary_key: 'opal_number', foreign_key: 'card_opal_number'
end
