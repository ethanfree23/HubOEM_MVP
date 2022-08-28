class AddTaxableToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :taxable, :boolean
  end
end
