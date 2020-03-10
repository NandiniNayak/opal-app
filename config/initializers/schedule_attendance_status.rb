class AttendanceStatus
  include Delayed::RecurringJob
  # task must be run mon, tue and wednesday for now. Future enhancement. based on the course schedule the task.
  # run_every 1.week
  # time = 1.minutes.from_now.strftime("%k:%M")
  # puts "TIME : #{time}===="
  # # run_at 'monday ' + time
  # run_at 'monday ' + 2.minutes.from_now.strftime("%k:%M")
  # run_at 'tuesday ' + time
  # run_at 'wednesday ' + 3.minutes.from_now.strftime("%k:%M")
  # # run_at 'wednesday ' + time
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
        late_pct = 0.6 * ((Attendance.where(:status => "Late").count) /  Attendance.all.where.not(checkin: nil).count.to_f)
        present_pct = ((Attendance.where(:status => "Present").count) /Attendance.all.where.not(checkin: nil).count.to_f)
        grade = (present_pct + late_pct) * 100
      end
      daily_attendance.update_columns(grade: grade)
      # update the grade on canvas for entry made each day
      update_canvas_grade(daily_attendance)
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
      if profile.card
        # if (!public_holiday)
          # check if attendance exists for the day
        if profile.card.attendances.exists?(:date => Date.today.to_s)
        #  first entry for the day must be a checkin for the card
          
         attendance = profile.card.attendances.where(:checkout => nil, :date => Date.today.to_s )
         attendance = attendance[0]
  
          if attendance.checkin && (attendance.checkin.in_time_zone('Sydney').strftime("%k:%M") <= start_time)
              attendance.update_columns(:status => "Present")
          elsif attendance.checkin && attendance.checkin.in_time_zone('Sydney').strftime("%k:%M").between?(start_time, end_time)
              attendance.update_columns(:status => "Late")
          end
        else
          # make an attendance entry for the day, with the status set to absent
           profile.card.attendances.create(:date => Date.today.to_s, :status => "Absent")
        end
        # end  # public holiday
        # calculate grade for each day for the first attendance entry, which will always be a checkin
        # daily_attendance = profile.card.attendances.find_by(:date => Date.today.to_s)
        daily_attendance = profile.card.attendances.where(:checkout => nil, :date => Date.today.to_s )
        calculate_grade(daily_attendance[0])
      end
    end
  end
end

# to be deployed
time = '19:00'

# just for test purpose
# time = 1.minutes.from_now.strftime("%k:%M")

AttendanceStatus.schedule(run_every: 1.week, run_at: ['monday ' + time, 'tuesday ' + time, 'wednesday '+ time], timezone: 'Sydney')
