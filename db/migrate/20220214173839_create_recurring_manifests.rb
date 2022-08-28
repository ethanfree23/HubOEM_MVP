class CreateRecurringManifests < ActiveRecord::Migration[7.0]
  def change
    create_table :recurring_manifests do |t|
      t.bigint :recurring_order, null: false, foreign_key: true
      t.references :obj, polymorphic: true
      t.integer :quantity

      t.timestamps
    end
  end
end
