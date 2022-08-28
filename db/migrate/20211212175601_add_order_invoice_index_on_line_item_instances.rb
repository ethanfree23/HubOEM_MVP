class AddOrderInvoiceIndexOnLineItemInstances < ActiveRecord::Migration[6.1]
  def change
    change_table :line_item_instances do |t|
      t.belongs_to :invoice
    end

  end
end
