class ChangeTimeToBeDateTimeInAttendance < ActiveRecord::Migration[5.2]
  def change
    # change_column :attendances, :chekin, :datetime
    # change_column :attendances, :chekout, :datetime

    remove_column :attendances, :chekin
    remove_column :attendances, :checkout
    add_column :attendances, :checkin, :datetime
    add_column :attendances, :checkout, :datetime
  end
end
