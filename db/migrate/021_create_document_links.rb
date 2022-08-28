class CreateDocumentLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :document_links do |t|
      t.belongs_to :document
      t.integer :obj_type
      t.integer :obj_id
      t.timestamps
    end
  end
end
