class ChangeALotAboutPartQuotes < ActiveRecord::Migration[7.0]
  def change
    change_table :part_quotes do |t|
      t.bigint :purchaser_id, null: false, foreign_key: true
    end
  end
end