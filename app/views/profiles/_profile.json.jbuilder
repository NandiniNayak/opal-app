json.extract! profile, :id, :user, :role, :course_id, :created_at, :updated_at
json.url profile_url(profile, format: :json)
