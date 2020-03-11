class Course < ApplicationRecord
    has_many :profiles, dependent: :destroy
end
