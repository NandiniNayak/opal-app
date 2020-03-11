class CanvasController < ApplicationController

  def fetch_domain
    Rails.env == "development" ? Rails.application.credentials.domain[:dev] : Rails.application.credentials.domain[:production]
  end

  def create_course(course_params)
    if(!Course.exists?(:course_number => course_params[:course_number]))
      @course = Course.new(course_params)
      @course.save
    end
    # respond_to do |format|
    #   if @course.save 
    #       user_list = RestClient.get("https://coderacademy.instructure.com/api/v1/courses/#{course_id}/enrollments", headers= fetch_header)
    #       render json: user_list
    #       #  NOTE: the user list for the course can be stored in database. which holds user data -> name, sis id and email
    #   else
    #     format.json { render json: @course.errors, status: :unprocessable_entity }
    #   end
    # end
  end


  def create_profile(course_id)
    @course = Course.find_by(:course_number => course_id)
    enrollments = RestClient.get("https://coderacademy.instructure.com/api/v1/courses/#{course_id}/enrollments", headers= fetch_header)
    JSON.parse(enrollments.body).each do |enrollment|
      if(!Profile.exists?(user: enrollment["user"]))
        profile_params = {user: enrollment["user"], role: enrollment["role"]}
        @course.profiles.create(profile_params)
      end
    end
  end



   # NOTE : Token needs to be a canvas api key, which needs to be gerated by exporing developer keys on canvas, for now it is my account token
  def page
    uri = URI(params["launch_presentation_return_url"])
    # NOTE: update this code, instead of hardcoding the array position to fetch course id. build a logic to handle this
    course_id = uri.path.split('/')[2]

    # NOTE: update course database : Uncomment this later when Admin naviagtion is implemented
    course_name = params["context_title"]
    # fetch the course start and end date
    course = RestClient.get("https://coderacademy.instructure.com/api/v1/courses/#{course_id}", headers= fetch_header)
    puts "COURSE BODY : #{JSON.parse(course.body).inspect}======= start date: #{JSON.parse(course.body)["start_at"]}==="
    start_date = JSON.parse(course.body)["start_at"].in_time_zone("Sydney") if JSON.parse(course.body)["start_at"]
    end_date = JSON.parse(course.body)["end_at"].in_time_zone("Sydney") if JSON.parse(course.body)["end_at"]
    create_course({:name => course_name, :course_number => course_id,  :start_date => start_date, :end_date => end_date})
    # This will also be at the admin navigation level, but for now capture data at the student level
    create_profile(course_id)
    @profiles = Profile.all
  end
end
