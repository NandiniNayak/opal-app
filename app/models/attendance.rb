class Attendance < ApplicationRecord
  belongs_to :card, foreign_key: 'card_opal_number'

  def update_checkin(checkin)
    start_time = "10:00"
    end_time = "17:00"
    @attendance.chekin = checkin
    if checkin.in_time_zone('Sydney').strftime("%k:%M %p") <= "10:00"
      @attendance.status = "Present"
    elsif checkin.in_time_zone('Sydney').strftime("%k:%M %p").between?(start_time, end_time)
      @attendance.status = "Late"
    else
      @attendance.status = "Absent"
    end
  end


  def update_checkout(checkout)
    @attendance.checkout = checkout
  end
end
