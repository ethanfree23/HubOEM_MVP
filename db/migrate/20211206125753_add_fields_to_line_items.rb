class AddFieldsToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :name, :string

    add_index :line_item_instances, :order_id

    add_column :line_item_instances, :name, :string
    add_column :line_item_instances, :price_per_unit, :decimal, precision: 20, scale: 2
    add_column :line_item_instances, :shipping_per_unit, :decimal, precision: 20, scale: 2
    add_column :line_item_instances, :quantity, :decimal, precision: 20, scale: 2
    add_column :line_item_instances, :taxable, :boolean
    add_column :line_item_instances, :object_type, :bigint
    add_column :line_item_instances, :object_id, :bigint
  end
end
