  class RecurringManifest < ApplicationRecord
  belongs_to :recurring_order
  belongs_to :obj, polymorphic: true, optional: true
  has_one :vendor, through: :recurring_order
  has_one :purchaser, through: :recurring_order

  def self.fields
    {
      'quantity': 'integer',
    }
  end

  def price_per_unit
    obj.present? ? obj.price_per_unit : 0
  end

  def shipping_per_unit
    obj.present? ? obj.shipping_per_unit : 0
  end

  def taxable
    obj.present? ? obj.taxable : true
  end

  def name
    obj.present? ? obj.name : ''
  end

  def allowed?(current_user)
    true if current_user.group.recurring_manifests.include? self || current_user.elevation == 9
  end

end
