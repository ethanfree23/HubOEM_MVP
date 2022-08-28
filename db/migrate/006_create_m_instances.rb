class CreateMInstances < ActiveRecord::Migration[6.0]
  def change
    create_table :m_instances do |t|
      t.string :serial
      t.datetime :installDate

      t.string :name
      t.string :description

      t.belongs_to :facility, optional: true

      t.belongs_to :machine, optional: true
      t.belongs_to :group, optional: true

      t.bigint :manufacturer_id
      t.bigint :brand_id

      t.timestamps
    end
  end
end
