class RecurringOrderManifestDefaultNullObj < ActiveRecord::Migration[7.0]
  def change
    change_column_default :recurring_manifests, :obj_type, nil
    change_column_default :recurring_manifests, :obj_id, nil
  end
end
