class LineItemInstance < ApplicationRecord
  # TODO: REMOVE BELOW WHEN STABLE.
  belongs_to :order, optional: true
  belongs_to :line_item, optional: true

  belongs_to :invoice
  belongs_to :group, optional: true

  belongs_to :referenceable, polymorphic: true


  def self.name_self
    "Line Item Instance"
  end

  def group_id
    order.vendor_id
  end

  def name
    return line_item.name if line_item.present?

    return read_attribute :name if read_attribute :name

    'No Name Set'
  end

  def cost
    return line_item.cost if line_item.present?

    return read_attribute :cost if read_attribute :cost

    0
  end

  def shipping_per_unit
    return read_attribute :shipping_per_unit if read_attribute :shipping_per_unit

    0
  end

  def quantity
    return read_attribute :quantity if read_attribute :quantity

    1
  end

  def price_per_unit
    return read_attribute :price_per_unit if read_attribute :price_per_unit

    1
  end

  def taxable
    return read_attribute :taxable if read_attribute :taxable

    1
  end
  #   $ASSET_HASH = { 3 => Machine, 4 => MInstance, 5 => Part }

  def self.fields
    {
      'name': 'text',
      'description': 'text',
      'price_per_unit': 'currency',
      'shipping_per_unit': 'currency',
      'quantity': 'integer',
      'taxable': 'boolean'
    }
  end

  def group
    invoice.order.vendor
  end

end
