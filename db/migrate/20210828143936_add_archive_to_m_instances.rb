class AddArchiveToMInstances < ActiveRecord::Migration[6.0]
  def change
    add_column(:parts, :archive, :boolean, default: false)
  end
end
