class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards , id: false, primary_key: :opal_number do |t|
      t.primary_key :opal_number
      t.references :profile, foreign_key: true

      t.timestamps
    end
  end
end
