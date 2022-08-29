class CreatePartQuotes < ActiveRecord::Migration[6.0]
  def change
    create_table :part_quotes do |t|
      t.references :p_instance, null: false, foreign_key: true
      t.integer :duration
      t.datetime :quote_date

      t.timestamps
    end
  end
end
