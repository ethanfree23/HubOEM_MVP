class AddStringFieldToStripeLogs < ActiveRecord::Migration[6.0]
  def change
    add_column :stripe_logs, :event, :string
  end
end
