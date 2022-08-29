class CreateParts < ActiveRecord::Migration[6.0]
  def change
    create_table :parts do |t|
      t.belongs_to :group

      t.integer :manufacturer_id
      t.integer :brand_id

      t.string :name
      t.text :description
      t.string :qrHash

      t.integer :priority, default: 0
      t.float :cost
      t.string :mfr_string

      t.integer :timeToService
      t.integer :warrantyDuration
      t.integer :recommendedStock

      t.decimal :orderPricePerUnit, precision: 15, scale: 10
      t.decimal :orderShippingPerUnit, precision: 15, scale: 10
      t.integer :orderMinQuantity
      t.integer :orderDeliveryTime
      t.integer :orderLeadTime

      t.string :drawing_number
      t.string :part_number
      t.string :warehouse_location
      t.string :vendor_name
      t.string :vendor_number


      t.timestamps
    end
  end
end
