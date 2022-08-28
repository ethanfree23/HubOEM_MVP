class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.integer :elevation
      t.string :addressShipping
      t.string :addressBilling
      t.string :phone
      t.float :taxrate

      t.timestamps
    end
  end
end
