class AddForgeFieldsToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :forge_object_id, :string
    add_column :documents, :forge_status, :string
    add_column :documents, :forge_urn, :string
  end
end
