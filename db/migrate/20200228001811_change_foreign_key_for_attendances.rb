class ChangeForeignKeyForAttendances < ActiveRecord::Migration[5.2]
  def change
      rename_column :attendances, :card_id, :card_number
  end
end
