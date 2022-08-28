class PInstance < ApplicationRecord
  belongs_to :part
  belongs_to :m_instance
  has_one :group, through: :m_instance
  has_many :documents, through: :part

  def self.find_by_group(current_user)
    current_user.p_instances
  end

  def self.name_self
    'Part Instance'
  end

  def name
    "#{part.name} #{m_instance.serial}"
  end

  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    val = true if user.group_id == m_instance.group_id
    val = true if user.group_id == part.group_id
    val
  end

  def orderPricePerUnit
    if part.orderPricePerUnit.present? && part.orderPricePerUnit != 0
      part.orderPricePerUnit
    elsif PartQuote.valid_quote(self).present?
      PartQuote.valid_quote(self).amount
    else
      ActionController::Base.helpers.link_to 'Request a quote', Rails.application.routes.url_helpers.new_part_quote_path(p_instance_id: id)
    end
  end

  def orderShippingPerUnit
    if part.orderShippingPerUnit.present? && part.orderShippingPerUnit != 0
      part.orderShippingPerUnit
    elsif PartQuote.valid_quote(self).present?
      PartQuote.valid_quote(self).shipping
    else
      0
    end
  end


end
