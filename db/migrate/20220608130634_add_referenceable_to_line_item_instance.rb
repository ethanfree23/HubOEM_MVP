class AddReferenceableToLineItemInstance < ActiveRecord::Migration[7.0]
  def change
    add_reference :line_item_instances, :referenceable, polymorphic: true, null: false
  end
end
