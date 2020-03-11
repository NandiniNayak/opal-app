class AttendanceStatusLatest
  include Delayed::RecurringJob

    def update_canvas_grade(attendance, course)
        # NOTE: fetch assignment id from canvas as macro (do not hardcode)
        sis_id = attendance.card.profile.user["sis_user_id"]
        course_id = course.course_number
        grade = attendance.grade
        url = "https://coderacademy.instructure.com/api/v1/courses/#{course_id}/assignments/1420/submissions/sis_user_id:#{sis_id}"
        payload = {"submission": {"posted_grade": grade }}

        if sis_id
        response = HTTParty.put(url, :body => payload.to_json, :headers => { "Content-Type" => 'application/json', "Authorization" => Rails.application.credentials.canvas[:authorization_key]})
        end
    end

    def calculate_grade(daily_attendance, profile, course)
        # if attendance for the course exists
      if profile.card && profile.card.attendances.exists?
        # Note: only 60% of the total attendance is give for late status.
        total_count = profile.card.attendances.where.not(checkin: nil).count + profile.card.attendances.where(status: "Absent").count
        late_pct = 0.6 * ((profile.card.attendances.where(:status => "Late").count) / total_count.to_f)
        present_pct = ((profile.card.attendances.where(:status => "Present").count) / total_count.to_f)
        grade = (present_pct + late_pct) * 100
      end
      daily_attendance.update_columns(grade: grade)
      # update the grade on canvas for entry made each day
      update_canvas_grade(daily_attendance, course)
    end

    def perform
        start_time = "10:00"
        end_time = "17:00"
        Course.all.each do |course|
            start_date = course.start_date
            end_date = course.end_date
            name = course.name
                    
            # check the date when the job runs falls in the course range
            if Date.today.between?(start_date, end_date)
                # loop through the days from start date till the previous day
                start_date.upto(Date.yesterday) do |each_day|
                    # FUTURE UPDATE: based on the course name run on specific days
                    # FUTURE UPDATE: Also include a check to see if its not a public holiday
                    if((each_day.strftime("%a") == "Mon" ) || (each_day.strftime("%a") == "Tue" ) || (each_day.strftime("%a") == "Wed" ))
                        course.profiles && course.profiles.each do |profile|
                                # if an attendance exists for each day
                            if profile.card && profile.card.attendances.exists?(:date => each_day.to_s)
                                # check if the status is already updated for the day
                                if profile.card  && profile.card.attendances.where(:date => each_day.to_s).where.not(status: nil).empty?
                                    # find the checkin entry who status is still not updated for the day
                                    attendance = profile.card.attendances.where(:date => each_day.to_s).where.not(checkin: nil)[0] if profile.card
                                    
                                    if attendance && attendance.checkin && (attendance.checkin.in_time_zone('Sydney').strftime("%k:%M") <= start_time)
                                        attendance.update_columns(:status => "Present")
                                    elsif attendance && attendance.checkin && attendance.checkin.in_time_zone('Sydney').strftime("%k:%M").between?(start_time, end_time)
                                        attendance.update_columns(:status => "Late")
                                    end

                                end
                            else
                                # make an entry for that day with status set to absent
                                profile.card && profile.card.attendances.create(:date => each_day.to_s, :status => "Absent")
                            end
                            # check if grade is already updated for the day : this will either return 1 entry or none, as grade gets updated with checkin or absent
                            if profile.card && profile.card.attendances.where(:date => each_day.to_s).where.not(grade: nil).empty?
                                daily_attendance = profile.card.attendances.where(:date => each_day.to_s ).where.not(checkin: nil) if profile.card
                                calculate_grade(daily_attendance[0], profile, course) if !daily_attendance.empty?
                            end
                        end
                    end
                end
            end
        end
    end
end

  # to be deployed
# time = '19:00'

# just for test purpose
time = 1.minutes.from_now.strftime("%k:%M")

AttendanceStatusLatest.schedule(run_every: 1.week, run_at: ['monday ' + time, 'tuesday ' + time, 'wednesday '+ time], timezone: 'Sydney')