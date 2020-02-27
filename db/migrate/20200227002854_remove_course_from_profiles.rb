class RemoveCourseFromProfiles < ActiveRecord::Migration[5.2]
  def change
    remove_reference :profiles, :course, foreign_key: true
  end
end
