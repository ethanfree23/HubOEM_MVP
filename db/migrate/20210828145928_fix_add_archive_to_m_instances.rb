class FixAddArchiveToMInstances < ActiveRecord::Migration[6.0]
  def change
    add_column :m_instances, :archive, :boolean, default: false
    remove_column :parts, :archive
  end
end
