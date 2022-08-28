class AddMiscFiendsToInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :name, :string
    add_column :invoices, :description, :string

  end
end
