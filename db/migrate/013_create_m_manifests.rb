class CreateMManifests < ActiveRecord::Migration[6.0]
  def change
    create_table :m_manifests do |t|
      t.belongs_to :order
      t.belongs_to :cart

      t.integer :m_instance_id

      t.timestamps
    end
  end
end
