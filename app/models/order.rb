###
class Order < ApplicationRecord
  belongs_to :purchaser, class_name: 'Group'
  belongs_to :vendor, class_name: 'Group'


  has_many :p_manifests, dependent: :delete_all
  has_many :parts, -> { distinct }, through: :p_manifests

  has_many :m_manifests, dependent: :delete_all
  has_many :m_instances, -> { distinct }, through: :m_manifests
  has_many :machines, -> { distinct }, through: :m_instances

  has_many :invoices, dependent: :delete_all
  has_many :line_item_instances, through: :invoices

  has_many :payments, through: :invoices

  has_many :tracking_info

  # some virtual variables for dealing with line items
  attr_accessor :new_line_item_desc, :new_line_item_cost, :line_item_selected

  after_create :send_create_email
  
  def paid?
    paid = true
    invoices.each do |invoice|
      paid = paid & invoice.paid?
    end
  end

  def documents
    []
  end

  def subtotals
    taxable = taxfree = shipping = 0
    invoices.each do |invoice|
      tax, free, _shipping = invoice.subtotals
      taxable += tax
      taxfree += free
      shipping += _shipping
    end
    cost = taxable + taxfree
    tax = taxable * vendor.taxrate
    total = cost + tax + shipping

    [cost, shipping, tax, total]
  end

  def line_item_subtotal
    line_item_instances.pluck(:cost).sum
  end

  def total
    _cost, _ship, _tax, _total = subtotals
    _total
  end

  # STATUSES:
  # #   | SHIPPING | MAINTNENCE  | HOW TO CHANGE
  # NIL | NOTHING  | NOTHING     | DON'T. THIS MEANS NO ITEMS ON THIS ORDER.
  # 0   | NOT YET  | NOT YET     | ORDER SEEN/SHIPPED/PROPOSAL DATE
  # 1   | PENDING  | PENDING-CPG | CPG SUGGESTED DATE, OEM CONFIRMS/DENIES SETS NEW DATE
  # 2   | N/A      | PENDING-OEM | OEM "            ", CPG "                           "
  # 3   | SHIPPPED | SCHEDULED   | OEM UPLOADED TRACKING INFO, CPG HAS TO MARK RECEIVED/COMPLETED
  # 4   | RECEIVED | COMPLETED   |
  def status
    "#{self.s_status} #{self.m_status}"
  end

  def s_status_hash
    {
      0 => 'Part Order Created',
      1 => 'Part Order Pending',
      2 => 'Part Order in Lead Time',
      3 => 'Part Order Shipped',
      4 => 'Part Order Received',
      5 => 'Vendor waiting for payment.',
      6 => '',
      7 => '',
    }
  end

  def shipped?
    shipping_status.present?
  end

  def s_status
    shipping_status.nil? ? '' : s_status_hash[shipping_status]
  end

  def m_status_hash
    {
      0 => 'Maintenance Order Created',
      1 => 'CPG Suggested Date',
      2 => 'OEM Suggested Date',
      3 => 'Maintnence Order Scheduled',
      4 => 'Maintnence Order Completed',
      5 => 'OEM Awaiting Pre-Authorization',
    }
  end

  def m_status
    maint_status.nil? ? '' : m_status_hash[maint_status]
  end

  def self.find_by_group(current_user)
    return Order.all if current_user.group.elevation == 9

    current_user.cpg_orders + current_user.oem_orders
  end

  def self.name_self
    'Order'
  end

  def name
    "Order #{id} #{created_at}"
  end

  def allowed?(user)
    val = false
    val = true if (user.group.elevation == 9) || (user.group_id == purchaser_id) || (user.group_id == vendor_id)
    val
  rescue NoMethodError
    false
  end

  def get_notificaiton_text
    text = "
    CPG Group #{self.purchaser.name} has placed an order with ID #{self.id}.<br>
    Shipping address:<br>
    #{self.purchaser.addressShipping}<br>
    Part Manifest: <br>
    "
    text += "
  <table>
    <tr>
      <th>Part</th>
      <th>Quantity</th>
      <th>Warehouse Location</th>
    </tr>"
    p_manifests.each do |pm|
      text += "
    <tr>
      <td>#{pm.part.name}</td>
      <td>#{pm.quantity}</td>
      <td>#{pm.part.warehouse_location}</td>
    </tr>"
    end
    text += '</table><br>'
  end

  def parts
    ps = []
    line_item_intances.each do |line_item_instance|
      case line_item_instance.linked_object
      when Part
        ps << line_item_instance.linked_object
      when PInstance
        ps << line_item_instance.linked_object.part
      when PManifest
        ps << line_item_instance.linked_object.part
      else
        next
      end
    end
    ps
  end

  def send_create_email
    SendOrderEmailNotificationToGroupJob.set(wait: 20.seconds).perform_later(vendor_id, self, get_notificaiton_text, 'HubOEM Order Placed!')
  end

  def send_email_to_purchaser
    SendOrderEmailNotificationToGroupJob.set(wait: 20.seconds).perform_later(purchaser_id, self, get_notificaiton_text, 'Order Update') # TODO: Should this have the order ID?
  end

  def send_email_w_param(group_id, notificaiton_text, subject)
    SendOrderEmailNotificationToGroupJob.set(wait: 20.seconds).perform_later(group_id, self, notificaiton_text, subject)
  end

  def unlocked_invoices
    invoices.where.not locked:true
  end

  def unlocked_invoices?
    unlocked_invoices.length > 0
  end

  def locked_invoices
    invoices.where locked:true
  end

  def unpaid_locked_invoices
    locked_invoices.filter { |invoice| invoice.paid? }
  end

  def unpaid_locked_invoices?
    unpaid_locked_invoices.length > 0
  end

  def completed_order?
    !unlocked_invoices? && !unpaid_locked_invoices? && shipped?
  end

  def incomplete_order?
    !completed_order?
  end

  # Dear god I hate this. This needs to be easier to read.
  #
  # Is this AI? << Butterfly meme.
  #
  # Explanation of above: I had this all in a lot of nested if statements. This is MUCH MUCH MUCH PRETTIER.
  def get_text
    return "#{name} - Completed." if completed_order?
    return "#{name} - Order has unlocked and unpaid invoices" if unlocked_invoices? && unpaid_locked_invoices?
    return "#{name} - Order has unlocked invoices" if unlocked_invoices?
    return "#{name} - Order has unpaid invoices" if unpaid_locked_invoices?
    return "#{name} - Order awaiting shipping status" unless shipped?
    "#{name}"
  end

end
