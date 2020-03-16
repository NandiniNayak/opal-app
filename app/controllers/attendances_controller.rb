class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:edit, :update, :destroy]

  # GET /attendances
  # GET /attendances.json
  def index
    # UNCOMMENT THIS CODE after hardware test: show the attendance of each user
    # profile.card.attendances
    @profile = Profile.find(params[:profile_id])
    if @profile.card
       @attendances = @profile.card.attendances
    else 
      @attendances = nil
    end
    # @attendances= Attendance.all
  end

  # GET /attendances/1
  # GET /attendances/1.json
  def show
    @profile = Profile.find(params[:profile_id])
    if @profile.card
       @attendances = @profile.card.attendances.where.not(checkout: nil)
    else 
      @attendances = nil
    end
  end

  # GET /attendances/new
  def new
    @attendance = Attendance.new
  end

  # GET /attendances/1/edit
  def edit
  end

  # POST /attendances
  # POST /attendances.json
  def create
    # find the card
    @card = Card.find(attendance_params[:card_opal_number])
    @attendance = Attendance.new(attendance_params)

    # update the attendance status for the first checkin of the day, subsequent tap on are logged just for reference as checkout, but not used for determining the attendance status and grade
    @attendance = @card.attendances.exists?(:date => Date.today.to_s) ? Attendance.update_checkout(params[:time], @attendance) : Attendance.update_checkin(params[:time], @attendance)
    # test code to check if the grade was updated as expected
    # @attendance = Attendance.update_checkin(params[:time], @attendance)
    respond_to do |format|
      if @attendance.save
            # Non nil checkin value, implies this is the first tap for the day, check if an entry exists for previous day, if not found update previous days status to absent 
            # if((@attendance.checkin != nil) &&(!@card.attendances.exists?(:date => Date.yesterday.to_s)))
            #    Attendance.create(:date => Date.yesterday.to_s, :status =>  "Absent", :card_opal_number => @card.opal_number)
            # end
        format.html { redirect_to @attendance, notice: 'Attendance was successfully created.' }
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attendances/1
  # PATCH/PUT /attendances/1.json
  def update
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to @attendance, notice: 'Attendance was successfully updated.' }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1
  # DELETE /attendances/1.json
  def destroy
    @attendance.destroy
    respond_to do |format|
      format.html { redirect_to attendances_url, notice: 'Attendance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attendance
      @attendance = Attendance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attendance_params
      params.require(:attendance).permit(:date, :checkin, :checkout, :status, :grade, :card_opal_number)
    end
end
