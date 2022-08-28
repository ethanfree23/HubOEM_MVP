class CreateMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :machines do |t|

      t.integer :manufacturer_id
      t.integer :brand_id

      t.string :name
      t.text :description

      t.belongs_to :group

      t.timestamps
    end
  end
end
