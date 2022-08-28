class AddBoolApplyAllToPartQuotes < ActiveRecord::Migration[7.0]
  def change
    change_table :part_quotes do |t|
      t.boolean :apply_all, default: false
    end
  end
end
