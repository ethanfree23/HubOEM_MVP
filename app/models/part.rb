class Part < ApplicationRecord
  include CustomFields
  belongs_to :group
  belongs_to :manufacturer, class_name: 'Group', optional: true
  belongs_to :brand, class_name: 'Group', optional: true

  has_many :parts_in_machines, dependent: :delete_all
  has_many :machines, through: :parts_in_machines

  has_many :p_instances, dependent: :delete_all
  has_many :consumers, class_name: 'Group', through: :p_instances, source: :group

  has_one_attached :avatar
  validates :avatar, content_type: ['image/png', 'image/jpg', 'image/jpeg'],
            size: { less_than: 10.megabytes , message: 'Part Image too large.' }

  has_many :document_links, as: :obj
  has_many :documents, through: :document_links


  def self.find_by_group(current_user)
    if current_user.group.elevation == 9
      return Part.all
    end
    current_user.parts
  end

  def gen_fields
    [:manufacturer,:name,:description,:qrHash,:group]
  end

  def detail_fields
    [:timeToService,:warrantyDuration,:reccommendedStock,:quantityInMachine]
  end

  def order_fields
    [:orderPricePerUnit,:orderShippingPerUnit,:orderMinQuantity,:orderDeliveryTime]
  end

  def fields
    gen_fields + detail_fields + order_fields
  end

  def self.name_self
    'Part'
  end

  def allowed?(user)
    return true if user.group.elevation == 9
    return true if user.group_id == group_id
    return true if user.group.cpg_parts.include? self
    false
  rescue NoMethodError
    return false
  end

  def orderPricePerUnit
    read_attribute(:orderPricePerUnit) || 0
  end

  def price_per_unit
    orderPricePerUnit
  end

  def shipping_per_unit
    orderShippingPerUnit
  end

  def orderShippingPerUnit
    read_attribute(:orderShippingPerUnit) || 0
  end

  def orderMinQuantity
    read_attribute(:orderMinQuantity) || 0
  end

  def orderDeliveryTime
    read_attribute(:orderDeliveryTime) || 1
  end

  def orderLeadTime
    read_attribute(:orderLeadTime) || 1
  end

  def name
    read_attribute(:name) || "Nameless, ID: #{id}"
  end

  def cost
    read_attribute(:cost) || 1
  end

  def taxable
    true
  end

  def version_by_date(date)
    part_version = versions.where('created_at < ?', date).last
    part_version.reify.present? ? part_version.reify : self
  end

  # Events: 1: Create, 2: Update, 3: Delete

end
