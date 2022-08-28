class ChangeOrderIdColNameOnInvoices < ActiveRecord::Migration[6.1]
  def change
    change_table :invoices do |t|
      t.remove_references :orders
      t.belongs_to :order
    end
  end
end
