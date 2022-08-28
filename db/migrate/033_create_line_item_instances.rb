class CreateLineItemInstances < ActiveRecord::Migration[6.0]
  def change
create_table :line_item_instances do |t|
      t.integer :order_id
      t.integer :group_id
      t.integer :line_item_id
      t.string :description
      t.decimal :cost, precision: 20, scale: 2

      t.timestamps
    end
  end
end
