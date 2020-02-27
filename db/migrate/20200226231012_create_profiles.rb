class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.jsonb :user
      t.string :role
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
