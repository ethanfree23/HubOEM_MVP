class AddLockedToInvoices < ActiveRecord::Migration[6.0]
  def change
    change_table :invoices do |t|
      t.boolean :locked
    end
  end
end
