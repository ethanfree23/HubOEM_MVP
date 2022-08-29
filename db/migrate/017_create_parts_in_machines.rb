class CreatePartsInMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :parts_in_machines do |t|
      t.belongs_to :machine
      t.belongs_to :part

      t.integer :quantity


      t.timestamps
    end
  end
end
