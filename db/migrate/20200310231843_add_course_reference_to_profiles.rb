class AddCourseReferenceToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_reference :profiles, :course, foreign_key: true
  end
end
