class AddPriceToPartQuotes < ActiveRecord::Migration[6.0]
  def change
    change_table :part_quotes do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.references :group, null: false, foreign_key: true
      t.references :part, null: false, foreign_key: true

    end
  end
end
