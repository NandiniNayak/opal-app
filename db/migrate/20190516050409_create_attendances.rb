class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.string :opal_number

      t.timestamps
    end
  end
end
