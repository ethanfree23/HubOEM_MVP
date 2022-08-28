class CreateBulkUploadObjects < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_upload_objects do |t|
      t.integer :obj_type
      t.integer :obj_id
      t.boolean :run

      t.timestamps
    end
  end
end
