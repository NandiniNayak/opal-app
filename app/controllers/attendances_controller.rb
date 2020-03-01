class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:show, :edit, :update, :destroy]

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

    # if params date matches todays date then check if the attendance for the card already has a checkin for that date, if not update the checkin data else update checkout data
    @card = Card.find(attendance_params[:card_opal_number])
    @attendance = Attendance.new(attendance_params)
    @card.attendances.exists?(:date => Date.today) ? update_checkout(params[:time]) : update_checkin(params[:time])
    # based on the checkin time calculate the attendance status to be present, absent or late
    # update status only for checkin not checkout
    # update_status
    # if date taken from the card is today's date then set the tap_on status to true. and every subseqquent tap is logged into checkout and not considered for the status

    respond_to do |format|
      if @attendance.save
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
      params.require(:attendance).permit(:date, :chekin, :checkout, :status, :grade, :card_opal_number)
    end
end
