class AddShippingToPartQuotes < ActiveRecord::Migration[6.0]
  def change
    change_table :part_quotes do |t|
      t.decimal :shipping, precision: 10, scale: 2
    end
  end
end
