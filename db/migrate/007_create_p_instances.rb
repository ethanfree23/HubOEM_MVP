class CreatePInstances < ActiveRecord::Migration[6.0]
  def change
    create_table :p_instances do |t|
      t.belongs_to :m_instance
      t.belongs_to :part

      t.integer :quantity

      t.datetime :serviceDate
      t.timestamps
    end
  end
end
