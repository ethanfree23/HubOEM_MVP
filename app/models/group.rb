class Group < ApplicationRecord
  include StripeAPI

  has_many :users

  has_many :machines
  has_many :parts
  has_many :notifications
  has_many :facilities
  has_one :stripe_integration

  has_many :m_instances
  has_many :p_instances, through: :m_instances

  has_many :documents
  has_many :machine_documents, through: :m_instances, source: :machine_documents
  has_many :m_instance_documents, through: :m_instances, source: :linked_documents
  has_many :p_instance_documents, through: :p_instances, source: :documents

  def visible_documents
    (documents + machine_documents + m_instance_documents + p_instance_documents).uniq
  end

  has_many :conversations, lambda { |group|
    unscope(:where).where(sender_id: group.id).or(where(receiver_id: group.id))
  }
  has_many :messages, through: :conversations

  has_many :part_quotes

  has_many :oem_orders, class_name: 'Order', foreign_key: 'vendor_id'
  has_many :cpg_orders, class_name: 'Order', foreign_key: 'purchaser_id'
  has_many :orders, lambda { |group|
    unscope(:where).where(vendor_id: group.id).or(where(purchaser_id: group.id))
  }
  has_many :invoices, through: :orders
  has_many :line_item_instances, through: :invoices
  has_many :ordered_parts, through: :line_item_instances, source: :referenceable, source_type: Part.to_s do
    def recent(days)
      where('line_item_instances.created_at' > Time.now - days.days)
    end

    def order_count(days = 30)
      recent(days).group(:part_id).select('parts.*, SUM(line_item_instances.quantity) as count')
    end

    def order_frequency(days = 30)
      recent(days).group(:part_id).select('parts.*, (SUM(line_item_instances.quantity) / days) as frequency').order(frequency: :desc)
    end

    def order_volume(days = 30)
      recent(days).group(:part_id).select('parts.*, SUM(line_item_instances.quantity * line_item_instances.price) as volume').order(volume: :desc)
    end
  end

  has_many :payments, through: :orders

  has_many :recurring_orders, lambda { |group|
    unscope(:where).where(vendor_id: group.id).or(where(purchaser_id: group.id))
  }
  has_many :recurring_manifests, through: :recurring_orders

  has_many :cpg_parts, through: :p_instances, source: :part

  has_many :cpg_m_instances, through: :machines, source: :m_instances
  has_many :cpg_p_instances, through: :cpg_m_instances, source: :p_instances
  has_many :related_cpgs, through: :cpg_m_instances, source: :group

  has_many :oem_machines, through: :m_instances, source: :machine
  has_many :related_oems, through: :oem_machines, source: :group

  has_one_attached :avatar
  validates :avatar, content_type: ['image/png', 'image/jpg', 'image/jpeg'],
            size: { less_than: 10.megabytes , message: 'Logo too large.' }

  after_create :test_cart
  after_create :test_facility

  def cart
    Cart.find_or_create_by(group_id: id)
  end

  def cpg_documents

  end

  def test_cart
    cart
  end

  def test_facility
    unless facilities.present?
      if elevation == 2 # only create a facility for cpg users
        # set only base info, these will be changed by cpgs/oems later
        facility = Facility.new
        facility.group_id = id
        facility.name = name + ' Facility'
        facility.address_line1 = addressShipping
        facility.save!
      end
    end
  end

  def stripe_attached?
    if Rails.env.production?
      !si.email.nil?
    end
    false
  end

  def get_stripe_edit_link(path)
    get_access_account_link(self,path)
  end

  def stripe_enabled?
    stripe_integration.present? && get_stripe_account(self).charges_enabled
  end

  def si
    get_stripe_account(self)
  end

  def ensure_stripe
    self.stripe_integration.blank? ? self.si : nil
  end

  # TODO: Change these functions to joins.
  def related_groups
    associations = []
    case elevation
    when 9
      Group.all.each do |g|
        associations << g
      end
    when 1
      associations += oem_related_groups
    when 2
      associations += cpg_related_groups
    else
      # Nothing
    end
    #associations << self
    associations.uniq.reject { |item| item.nil? || item == '' }
  end

  def oem_related_groups
    case elevation
    when 9
      Group.where(elevation: 1)
    else
      related_oems
    end
  end

  def cpg_related_groups
    case elevation
    when 9
      Group.where(elevation: 2)
    else
      related_cpgs
    end
  end

  def self.find_by_group(current_user)
    current_user.group.related_groups
  end

  def allowed?(user)
    return true if user.group.elevation == 9
    return true if related_groups.include?(user.group)
    return true if user.group_id == id
    false
    rescue NoMethodError
      false
  end

  def type
    val = 'Unknown'
    case elevation
    when 0
      val = 'Unregistered'
    when 1
      val = 'OEM User'
    when 2
      val = 'CPG User'
    when 9
      val = 'Admin'
    end
    val
  end

  def self.name_self
    'User Group'
  end

  def get_emails
    User.where(:group_id => id).pluck(:email)
  end

  def corp_order_by_facility
    [
      {
        name: 'Parts',
        data: [['Facility 1', 10], ['Facility 2', 16], ['Facility 3', 28]]
      },
      {
        name: 'Service',
        data: [['Facility 1', 10], ['Facility 2', 16], ['Facility 3', 28]]
      },
      {
        name: 'Other',
        data: [['Facility 1', 10], ['Facility 2', 16], ['Facility 3', 28]]
      },
    ]
  end

  def corp_order_volume_by_vendor
    [
      {
        name: 'Parts',
        data: [['Acme Machine', 10], ['Wonka Grp', 16], ['Gear Co', 28]]
      },
      {
        name: 'Service',
        data: [['Acme Machine', 10], ['Wonka Grp', 16], ['Gear Co', 28]]
      },
      {
        name: 'Other',
        data: [['Acme Machine', 10], ['Wonka Grp', 16], ['Gear Co', 28]]
      },
    ]
  end

  def corp_order_value_by_vendor
    [
      {
        name: 'Parts',
        data: [['Acme Machine', 100], ['Wonka Grp', 160], ['Gear Co', 280]]
      },
      {
        name: 'Service',
        data: [['Acme Machine', 100], ['Wonka Grp', 160], ['Gear Co', 280]]
      },
      {
        name: 'Other',
        data: [['Acme Machine', 100], ['Wonka Grp', 160], ['Gear Co', 280]]
      },
    ]
  end

  def vendor_volume(type)
    other = type == 'oem' ? 'cpg' : 'oem'
    "
SELECT `#{other}`.`name`, sum(`pm`.`quantity`) as `Sum`
FROM `groups` as `oem`
         INNER JOIN `orders` ON `orders`.`vendor_id` = `oem`.`id`
         INNER JOIN `groups` as `cpg` ON `orders`.`purchaser_id` = `cpg`.`id`
         INNER JOIN `p_manifests` as `pm` ON `pm`.`order_id` = `orders`.`id`
WHERE `#{type}`.`id` = #{id}
GROUP BY `#{other}`.`id`
ORDER BY `Sum` desc
LIMIT 20
    "
  end

  def oem_vendor_volume
    execute_statement vendor_volume 'oem'
  end

  def cpg_vendor_volume
    execute_statement vendor_volume 'cpg'
  end

  def vendor_value(type)
    other = type == 'oem' ? 'cpg' : 'oem'
    "
SELECT `#{other}`.`name`, sum(`pm`.`quantity` * `parts`.`orderPricePerUnit`) as `Sum`
FROM `groups` as `oem`
         INNER JOIN `orders` ON `orders`.`vendor_id` = `oem`.`id`
         INNER JOIN `groups` as `cpg` ON `orders`.`purchaser_id` = `cpg`.`id`
         INNER JOIN `p_manifests` as `pm` ON `pm`.`order_id` = `orders`.`id`
         INNER JOIN `parts` ON `parts`.`id` = `pm`.`part_id`
WHERE `#{type}`.`id` = #{id}
GROUP BY `#{other}`.`id`
ORDER BY `Sum` desc
LIMIT 20
    "
  end

  def oem_vendor_value
    execute_statement vendor_value 'oem'
  end

  def cpg_vendor_value
    execute_statement vendor_value 'cpg'
  end

  def part_volume(type)
    "
SELECT `parts`.name, sum(`pm`.`quantity`) as `Sum`
FROM `orders`
         INNER JOIN `groups` as `oem` ON `orders`.`vendor_id` = `oem`.`id`
         INNER JOIN `groups` as `cpg` ON `orders`.`purchaser_id` = `cpg`.`id`
         INNER JOIN `p_manifests` as `pm` ON `pm`.`order_id` = `orders`.`id`
         INNER JOIN `parts` on `pm`.`id` = `parts`.`id`
WHERE `#{type}`.`id` = #{id}
GROUP BY `pm`.`part_id`
ORDER BY `Sum` desc
LIMIT 20
    "
  end

  def oem_part_volume
    execute_statement part_volume 'oem'
  end

  def cpg_part_volume
    execute_statement part_volume 'cpg'
  end

  def part_value(type)
    "
SELECT `parts`.name, sum(`pm`.`quantity` * `parts`.`orderPricePerUnit`) as `Sum`
FROM `orders`
         INNER JOIN `groups` as `oem` ON `orders`.`vendor_id` = `oem`.`id`
         INNER JOIN `groups` as `cpg` ON `orders`.`purchaser_id` = `cpg`.`id`
         INNER JOIN `p_manifests` as `pm` ON `pm`.`order_id` = `orders`.`id`
         INNER JOIN `parts` on `pm`.`id` = `parts`.`id`
WHERE `#{type}`.`id` = #{id}
GROUP BY `pm`.`part_id`
ORDER BY `Sum` desc
LIMIT 20
    "
  end

  def oem_part_value
    execute_statement part_value 'oem'
  end

  def cpg_part_value
    execute_statement part_value 'cpg'
  end

  def order_details(type)
    other = type == 'oem' ? 'cpg' : 'oem'
    "
SELECT `orders`.`id` as `Order`, `#{other}`.`name` as `#{other}`, `orders`.`created_at` as `Order_Date`, sum(`pm`.`quantity` * `parts`.`orderPricePerUnit`) as `Total`
FROM `orders`
         INNER JOIN `groups` as `oem` ON `orders`.`vendor_id` = `oem`.`id`
         INNER JOIN `groups` as `cpg` ON `orders`.`purchaser_id` = `cpg`.`id`
         INNER JOIN `p_manifests` as `pm` ON `pm`.`order_id` = `orders`.`id`
         INNER JOIN `parts` on `pm`.`id` = `parts`.`id`
WHERE `#{type}`.`id` = #{id}
GROUP BY `orders`.`id`
ORDER BY `orders`.`id` desc
"
  end

  def oem_order_details
    execute_query order_details 'oem'
  end

  def cpg_order_details
    execute_query order_details 'cpg'
  end

  def taxrate
    read_attribute(:taxrate) || 0
  end

  def minimum_order_amount
    read_attribute(:minimum_order_amount) || 0
  end

  def defer_payment_amount
    read_attribute(:defer_payment_amount) || 0
  end

  def unread_notifications
    notifications = (PartQuote.open_quotes(self) + Notification.unread(self))
    notifications += unlocked_invoices if elevation == 1
    notifications += unpaid_locked_invoices if elevation == 2
    notifications += unshipped_orders if elevation == 1
    notifications += pending_recurring_orders if elevation == 2
    notifications << cart if elevation == 2 && cart.has_items?
    notifications.reject { |e| e.blank? }
  end

  def recent_notifications
    now = Time.now
    (PartQuote.open_quotes(self) +
      Notification.recent(self) +
      Notification.unread(self).where("created_at": ..(now - 24.hours)) +
      unread_messages.where("created_at": ..(now - 24.hours)))
      .uniq
      .sort_by(&:created_at)
  end

  def unread_messages
    messages.where(read_status: 0, sender_id: id)
  end

  def unlocked_invoices
    invoices.where locked:true
  end

  def locked_invoices
    invoices.where.not locked:true
  end

  def unpaid_locked_invoices
    locked_invoices.filter { |invoice| invoice.paid? }
  end

  def incomplete_orders
    orders.filter { |order| order.incomplete_order? }
  end

  def unshipped_orders
    incomplete_orders.filter { |order| order.paid? && !order.shipped?}
  end

  def unlocked_orders
    incomplete_orders.filter { |order| order.unlocked_invoices? }
  end

  def unpaid_orders
    incomplete_orders.filter { |order| order.unpaid_locked_invoices? }
  end

  def recent_messages
    now = Time.now
    messages.where(created_at: (now - 24.hours)..now, sender_id: id)
  end

  def pending_recurring_orders
    RecurringOrder.where(purchaser_id: id, active: true)
                  .where("next_order_date <= ?", Date.today - 7.days)
  end

end
