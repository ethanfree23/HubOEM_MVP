class AddReferenceableToLineItemInstance < ActiveRecord::Migration[6.0]
  def change
    add_reference :line_item_instances, :referenceable, polymorphic: true, null: false, index: { name: "line_item_instance_idx" }
  end
end
