class Attendance < ApplicationRecord
  belongs_to :card, foreign_key: :card_number
end
