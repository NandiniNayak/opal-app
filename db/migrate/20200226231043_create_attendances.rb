class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.date :date
      t.time :checkin
      t.time :checkout
      t.string :status
      t.integer :grade
      t.references :card, foreign_key: true

      t.timestamps
    end
  end
end
