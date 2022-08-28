class LineItem < ApplicationRecord
  belongs_to :group

  attr_accessor :new_line_item_desc, :new_line_item_cost, :line_item_selected, :oem_group_id
  def self.name_self
    "Line Item"
  end

  def group_id
    group_id
  end
end
