class CreateLineItems < ActiveRecord::Migration[6.0]
  def change
    create_table :line_items do |t|
      t.belongs_to :groups
      t.string :description
      t.decimal :cost, precision: 20, scale: 2

      t.timestamps
    end
  end
end
