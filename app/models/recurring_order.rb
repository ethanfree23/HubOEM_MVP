class RecurringOrder < ApplicationRecord
  belongs_to :purchaser, class_name: 'Group'
  belongs_to :vendor, class_name: 'Group'
  has_many :recurring_manifests
  has_many :objs, through: :recurring_manifests
  
  def create_order
    order = Order.new(purchaser: purchaser,
                       vendor: vendor,
                       maint_status: 0,
                       shipping_status: 0,
                       po: purchase_order
                       )
    order.save!

    Notification.create(group: order.purchaser, obj_type: 7, obj_id: order.id, notification_type: 1, read: false)
    Notification.create(group: order.vendor, obj_type: 7, obj_id: order.id, notification_type: 1, read: false)

    recurring_manifests.each do |recurring_manifest|
      obj = recurring_manifest.obj
      case obj
      when Part
        p = obj
        @invoice = if p.orderPricePerUnit.present? && !p.orderPricePerUnit.is_a?(String) && p.orderPricePerUnit > 0
                     Invoice.where(order_id: order.id, name: "Order #{order.id} Parts Invoice").first_or_create
                   else
                     Invoice.where(order_id: order.id, name: "Order #{order.id} Quote Invoice").first_or_create
                   end
      when Machine
        @invoice = Invoice.where(order_id: order.id, name: "Order #{order.id} Maintenance Invoice").first_or_create

      else
        @invoice = Invoice.where(order_id: order.id, name: "Order #{order.id} Misc Invoice").first_or_create
      end
      @invoice.add_line_item obj, recurring_manifest.quantity
    end
    order
  end

  def add_manifest(obj, quantity = 1)
    RecurringManifest.create!(recurring_order: self,
                              obj: obj,
                              quantity: quantity)
  end

  def allowed?(current_user)
    current_user.group.recurring_orders.include? self || current_user.elevation == 9
  end

  def get_text
    "Your recurring order #{name} that will be placed soon. Please review and make any necessary changes. Thank you!"
  end
  
end
