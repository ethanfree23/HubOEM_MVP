class CreateStripeLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :stripe_logs do |t|

      t.timestamps
    end
  end
end
