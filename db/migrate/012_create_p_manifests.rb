class CreatePManifests < ActiveRecord::Migration[6.0]
  def change
    create_table :p_manifests do |t|
      t.belongs_to :order
      
      t.belongs_to :cart
      t.belongs_to :part

      t.integer :quantity

      t.timestamps
    end
  end
end
