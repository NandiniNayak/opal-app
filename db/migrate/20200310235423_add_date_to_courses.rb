class AddDateToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :start_date, :Date
    add_column :courses, :end_date, :Date
  end
end
