json.extract! attendance, :id, :date, :chekin, :checkout, :status, :grade, :card_id, :created_at, :updated_at
json.url attendance_url(attendance, format: :json)
