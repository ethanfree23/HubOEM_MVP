class AddForgeToMachines < ActiveRecord::Migration[6.1]
  def change
    add_column :machines, :forge_object_id, :string
    add_column :machines, :forge_status, :string
    add_column :machines, :forge_urn, :string
    add_column :m_instances, :forge_object_id, :string
    add_column :m_instances, :forge_status, :string
    add_column :m_instances, :forge_urn, :string
  end
end
