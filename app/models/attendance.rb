class Attendance < ApplicationRecord
  belongs_to :card, foreign_key: 'card_opal_number'
  after_create :calculate_grade
  after_save :update_canvas_grade

  # self keyword lets us access model methods from controller
  def self.update_checkin(checkin, attendance)
    start_time = "10:00"
    end_time = "17:00"

    attendance.checkin = checkin
    if checkin.in_time_zone('Sydney').strftime("%k:%M %p") <= "10:00"
      attendance.status = "Present"
    elsif checkin.in_time_zone('Sydney').strftime("%k:%M %p").between?(start_time, end_time)
      attendance.status = "Late"
    else
      attendance.status = "Absent"
    end
    return attendance

  end

  def self.update_checkout(checkout, attendance)
    attendance.checkout = checkout
    return attendance
  end

  def calculate_grade
    if self.checkin
          # update grade
      if Attendance.all.count > 0
        # Note: only 60% of the total attendance is give for late status.
        late_pct = 0.6 * ((Attendance.where(:status => "Late").count) /  Attendance.all.count.to_f)
        present_pct = ((Attendance.where(:status => "Present").count) / Attendance.all.count.to_f)
        grade = (present_pct + late_pct) * 100
      end
      self.update_columns(grade: grade)
    end
  end

  def update_canvas_grade

    # fetch course Id and assignment id from canvas as macros (do not hardcode)
    sis_id = self.card.profile.user["sis_user_id"]
    grade = self.grade
    url = "https://coderacademy.instructure.com/api/v1/courses/224/assignments/1420/submissions/sis_user_id:#{sis_id}"
    payload = {"submission": {"posted_grade": grade }}

    if sis_id
      response = HTTParty.put(url, :body => payload.to_json, :headers => { "Content-Type" => 'application/json', "Authorization" => Rails.application.credentials.canvas[:authorization_key]})
    end

  end

end
