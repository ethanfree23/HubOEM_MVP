class AddInvoiceIdToPayments < ActiveRecord::Migration[7.0]
  def change
    change_table :payments do |t|
      t.bigint :invoice_id, null: false, foreign_key: true
    end
  end
end
