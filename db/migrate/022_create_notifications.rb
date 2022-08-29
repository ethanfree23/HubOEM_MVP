class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.integer :obj_type, null: false
      t.integer :obj_id, null: false
      t.integer :notification_type, null: false
      t.boolean :read, null: false
      t.belongs_to :group, null: false

      t.timestamps
    end
  end
end
