class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.string :file_loc
      t.belongs_to :group
      t.string :name
      t.boolean :process_status

      t.timestamps
    end
  end
end
