class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.date :date
      t.time :chekin
      t.time :checkout
      t.string :status
      t.integer :grade
      t.references :card_opal_number, references: :cards, null: false

      t.timestamps
    end

    rename_column :attendances, :card_opal_number_id, :card_opal_number
    add_foreign_key :attendances, :cards, column: 'card_opal_number', primary_key: 'opal_number'
  end
end
