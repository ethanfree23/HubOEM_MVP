class ChangeEventFieldStripeLogs < ActiveRecord::Migration[6.0]
  def change

    remove_column :stripe_logs, :event, :string
    add_column :stripe_logs, :event, :text
  end
end
