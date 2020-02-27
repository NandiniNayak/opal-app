class CanvasController < ApplicationController

  def fetch_domain
    Rails.env == "development" ? Rails.application.credentials.domain[:dev] : Rails.application.credentials.domain[:production]
  end

  def create_course(course_params, course_id)
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save 
          user_list = RestClient.get("https://coderacademy.instructure.com/api/v1/courses/#{course_id}/enrollments", headers= fetch_header)
          render json: user_list
          #  NOTE: the user list for the course can be stored in database. which holds user data -> name, sis id and email
      else
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end


  def create_profile(course_id)
    enrollments = RestClient.get("https://coderacademy.instructure.com/api/v1/courses/#{course_id}/enrollments", headers= fetch_header)
    JSON.parse(enrollments.body).each do |enrollment|
      if(!Profile.exists?(user: enrollment["user"]))
        profile_params = {user: enrollment["user"], role: enrollment["role"]}
        Profile.create(profile_params)
      end
    end
  end



   # NOTE : Token needs to be a canvas api key, which needs to be gerated by exporing developer keys on canvas, for now it is my account token
  def page
    uri = URI(params["launch_presentation_return_url"])
    # NOTE: update this code, instead of hardcoding the array position to fetch course id. build a logic to handle this
    course_id = uri.path.split('/')[2]

    # NOTE: update course database : Uncomment this later when Admin naviagtion is implemented
    # course_name = params["context_title"]
    # create_course({name: course_name}, course_id)
    # This will also be at the admin navigation level, but for now capture data at the student level
    create_profile(course_id)
    @profiles = Profile.all
  end
end
