class CreateRecurringOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :recurring_orders do |t|
      t.string :purchase_order
      t.bigint :purchaser_id, null: false
      t.bigint :vendor_id, null: false
      t.boolean :active
      t.string :name
      t.datetime :next_order_date
      t.integer :days_between_orders

      t.timestamps
    end
  end
end
