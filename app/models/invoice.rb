###
class Invoice < ApplicationRecord
  belongs_to :order

  has_many :line_item_instances, dependent: :delete_all
  has_many :line_items, -> { distinct }, through: :line_item_instances

  has_many :payments

  def paid?
    payments.each do |payment|
      return true if payment.accepted?
    end
    false
  end

  def subtotals
    shipping = taxable_subtotal = taxfree_subtotal = 0
    line_item_instances.each do |line_item|
      shipping += line_item.shipping_per_unit * line_item.quantity
      taxable_subtotal += line_item.taxable ? line_item.price_per_unit * line_item.quantity : 0
      taxfree_subtotal += !line_item.taxable ? line_item.price_per_unit * line_item.quantity : 0
    end
    [taxable_subtotal, taxfree_subtotal, shipping]
  end

  def subtotal
    subtotals.sum
  end

  def total
    taxable_subtotal, taxfree_subtotal, shipping = subtotals
    taxable_subtotal = taxable_subtotal * ( 1 + order.vendor.taxrate )
    taxable_subtotal + taxfree_subtotal + shipping
  end

  # Parse out a given list of object(s) into this invoice. This should be be able to handle the previously built manifests.
  def add_line_item(objects)
    objects = [objects] unless objects.instance_of? Array
    objects.each do |object|
      case object
      when Part
        add_from_part object
      when PInstance
        add_from_p_instance object
      when PManifest
        add_from_p_manifest object, object.quantity
        object.delete
      when Machine
        # This doesn't work... yet.
      when MInstance
        add_from_m_instance object
      when MManifest
        add_from_m_instance object.m_instance
        object.delete
      when String
        add_from_string object
      when LineItem
        add_from_line_item object
      else
        # You sent something you shouldn't have. Why?
        next
      end
    end
    true
  end

  def add_from_part(part, quantity = 1, taxable = true)
    LineItemInstance.create!(invoice_id: id,
                             group_id: part.group_id,
                             price_per_unit: part.orderPricePerUnit,
                             shipping_per_unit: part.orderShippingPerUnit,
                             quantity: quantity,
                             taxable: taxable,
                             name: part.name,
                             description: "Line Item Entry for #{part.name}",
                             referenceable: part)
  end

  def add_from_p_manifest(p_manifest, quantity = 1, taxable = true)
    add_from_part p_manifest.part, quantity, taxable
  end

  def add_from_p_instance(p_instance, quantity = 1, taxable = true)
    LineItemInstance.create!(invoice_id: id,
                             group_id: p_instance.part.group_id,
                             price_per_unit: p_instance.orderPricePerUnit,
                             shipping_per_unit: p_instance.orderShippingPerUnit,
                             quantity: quantity,
                             taxable: taxable,
                             name: part.name,
                             description: "Line Item Entry for #{part.name}",
                             referenceable: p_instance)
  end

  def add_from_m_instance(m_instance, quantity = 1, cost = 0, taxable = false)
    puts order.inspect
    LineItemInstance.create!(invoice_id: id,
                             group_id: m_instance.group_id,
                             price_per_unit: cost,
                             quantity: quantity,
                             taxable: taxable,
                             name: m_instance.name,
                             description: "Line Item Entry for #{m_instance.name}",
                             referenceable: m_instance)
  end

  def add_from_line_item(line_item, quantity = 1)
    LineItemInstance.create!(invoice_id: id,
                             group_id: line_item.group_id,
                             price_per_unit: line_item.cost,
                             quantity: quantity,
                             taxable: line_item.taxable,
                             name: line_item.name,
                             description: line_item.description.to_s,
                             referenceable: line_item)
  end

  def add_from_string(string, taxable = true, quantity = 1)
    LineItemInstance.create!(invoice_id: id,
                             group_id: order.vendor_id,
                             price_per_unit: line_item.cost,
                             quantity: quantity,
                             taxable: taxable,
                             name: string,
                             description: "Line Item for #{string}")
  end

  def name
    return read_attribute :name if read_attribute :name

    "Invoice #{id}"
  end

  def remove_line_item(line_item)
    true if line_item_instances.include?(line_item) and line_item.destroy
    rescue
      false
  end

  def locked?
    return read_attribute :locked if read_attribute :locked

    true
  end

  def allowed?(user)
    return true if user.group.elevation == 9
    return true if [order.vendor, order.purchaser].include?(user.group)
    false
  rescue NoMethodError
    false
  end

  def get_text
    if locked?
      if paid?
        "#{name} - Invoice Paid"
      else
        "#{name} - Ready for Payment"
      end
    else
      "#{name} - Invoice unlocked, waiting for approval."
    end
  end

end
