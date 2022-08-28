class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.integer :vendor_id
      t.integer :purchaser_id

      t.integer :shipping_status
      t.integer :maint_status
      t.integer :requested_date
      t.datetime :request_date
      t.datetime :scheduled_date
      t.text :description
      t.datetime :shipped_date
      t.string :po

      t.timestamps
    end
  end
end
