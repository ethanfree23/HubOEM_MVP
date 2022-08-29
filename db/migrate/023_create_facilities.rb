class CreateFacilities < ActiveRecord::Migration[6.0]
  def change
    create_table :facilities do |t|
      t.text :address_line1
      t.text :address_line2
      t.string :city
      t.string :state
      t.integer :zipcode
      t.string :name

      t.belongs_to :group

      t.timestamps
    end
  end
end
