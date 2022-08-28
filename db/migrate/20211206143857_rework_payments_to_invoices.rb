class ReworkPaymentsToInvoices < ActiveRecord::Migration[6.1]
  def change
    change_table :payments do |t|
      # t.remove_references :order
      # t.belongs_to :invoice, null: false, foreign_key: true
    end
  end
end
