class CreateRevisions < ActiveRecord::Migration[6.0]
  def change
    create_table :revisions do |t|
      t.integer :object_type
      t.integer :object_id
      t.text :object_state
      t.integer :user_id
      t.integer :group_id
      t.integer :modification_type


      t.timestamps
    end
  end
end
