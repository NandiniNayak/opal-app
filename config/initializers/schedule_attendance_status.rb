class AttendanceStatus
  include Delayed::RecurringJob
  # task must be run mon, tue and wednesday for now. Future enhancement. based on the course schedule the task.
  # run_every 1.day
  # run_at '05:00PM'
  # queue 'slow-jobs'
  # timezone 'Sydney'
  
  def update_canvas_grade(attendance)

    # NOTE: fetch course Id and assignment id from canvas as macros (do not hardcode)
    sis_id = attendance.card.profile.user["sis_user_id"]
    grade = attendance.grade
    url = "https://coderacademy.instructure.com/api/v1/courses/224/assignments/1420/submissions/sis_user_id:#{sis_id}"
    payload = {"submission": {"posted_grade": grade }}

    if sis_id
      response = HTTParty.put(url, :body => payload.to_json, :headers => { "Content-Type" => 'application/json', "Authorization" => Rails.application.credentials.canvas[:authorization_key]})
    end
  end

  def calculate_grade(daily_attendance)
      if Attendance.all.count > 0
        # Note: only 60% of the total attendance is give for late status.
        late_pct = 0.6 * ((Attendance.where(:status => "Late").count) /  Attendance.all.count.to_f)
        present_pct = ((Attendance.where(:status => "Present").count) / Attendance.all.count.to_f)
        grade = (present_pct + late_pct) * 100
      end
      attendance = daily_attendance.update_columns(grade: grade)
      if attendance.save
        # update the grade on canvas for entry made each day
        update_canvas_grade(attendance)
      end
  end
  
=begin
    # Ignore the task if its a public holiday ( to be implemented, potentially expore holiday gem)
    # loop through every student and check if they have a attendance for the day logged. if so based on the time update the status to present or late
    # if no attendance logged, make an attendace entry with the status set to absent
=end

  def perform
    start_time = "10:00"
    end_time = "17:00"

    Profile.all.each do |profile|
        # if (!public_holiday)
          # check if attendance exists for the day
        if profile.card.attendances.exists?(:date => Date.today.to_s)
        #  first entry for the day must be a checkin for the card
          
         attendance = profile.card.attendances.find_by(:date => Date.today.to_s )

          if attendance.checkin.in_time_zone('Sydney').strftime("%k:%M %p") <= "10:00"
              attendance.status = "Present"
          elsif attendance.checkin.in_time_zone('Sydney').strftime("%k:%M %p").between?(start_time, end_time)
              attendance.status = "Late"
          end
        else
          # make an attendance entry for the day, with the status set to absent
           profile.card.attendances.create(:date => Date.today.to_s, :status => "Absent")
        end
        # end  # public holiday
        # calculate grade for each day for the first attendance entry, which will always be a checkin
        daily_attendance = profile.card.attendances.find_by(:date => Date.today.to_s)
        calculate_grade(daily_attendance)
    end
  end
end

# AttendanceStatus.schedule!
AttendanceStatus.schedule(run_every: 1.week, run_at: ['monday 2:30:00pm', 'tuesday 2:30pm', 'wednesday 2:30pm'], timezone: 'Sydney')
