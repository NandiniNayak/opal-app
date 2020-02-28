class AddUniqueConstraintsToCardNumbers < ActiveRecord::Migration[5.2]
  def change
    add_index :cards, :card_number, :unique => true
  end
end
