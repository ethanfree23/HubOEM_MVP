class FixRecurringManifestColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :recurring_manifests, :recurring_order, :recurring_order_id
  end
end
