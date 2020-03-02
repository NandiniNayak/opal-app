class Attendance < ApplicationRecord
  belongs_to :card, foreign_key: 'card_opal_number'
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
    # update grade
    if Attendance.all.count > 0
      # Note: dedcut 2% from actual percentage for late status.

      late_pct = ((Attendance.where(:status => "Late").count) /  Attendance.all.count)) - 0.2
      present_pct = ((Attendance.where(:status => "Present").count) / Attendance.all.count) 
      attendance.grade = present_pct + late_pct
    end
    return attendance
  end

  def self.update_checkout(checkout, attendance)
    attendance.checkout = checkout
    return attendance
  end


  def update_canvas_grade
    # fetch course Id and assignment id from canvas as macros (do not hardcode)
    https://coderacademy.instructure.com/api/v1/courses/224/assignments/1420/submissions/sis_user_id:#{sis_id}
    axios.pus()
  end

end
