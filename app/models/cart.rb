class Cart < ApplicationRecord
  belongs_to :group

  has_many :p_manifests, dependent: :destroy
  has_many :parts, -> { distinct }, through: :p_manifests

  has_many :m_manifests, dependent: :destroy
  has_many :m_instances, through: :m_manifests
  has_many :machines, through: :m_instances

  def parse
    ms = m_manifests
    mm_dict = {}
    # Carts have Manifests, Manifests have machine/part instances, instances
    #   have gernals, generals have OEMs.

    ms.each do |m|
      mm_dict[m.group.id].nil? ? mm_dict[m.group.id] = [m] : m_dict[mm.group.id] << m
    end
    # m_dict is now a dictionary of lists of machines by OEM. There shouldn't be
    #   a quantity there, so... yeah need to look at that.

    pm_dict = {}
    p_manifests.each do |pm|
      p = pm.part
      pm_dict[p.group.id].nil? ?       # If the array doesn't exist yet
        pm_dict[p.group.id] = [pm] :   # Create it.
        pm_dict[p.group.id] << pm      # Otherwise insert into it.
    end
    # So... p_dict is a hash of parts by OEM key. [oem] = [part_manifests], {id,part,quantity}

    # Set unique OEMs for this cart.
    uniq_oems = (mm_dict.keys + pm_dict.keys).uniq

    return mm_dict, pm_dict, uniq_oems
  end

  def self.subtotals(pms)
    if pms.present?
      cost = 0
      ship = 0
      pms.each do |pm|
        cost += pm.part.orderPricePerUnit * pm.quantity
        ship += pm.part.orderShippingPerUnit * pm.quantity
      end
      if pms[0].part.group.taxrate.present?
        tax = cost * pms[0].part.group.taxrate
      else
        tax = 0
      end
      total = cost+ship+tax
      return cost, ship, tax, total
    end
    return total, 0, 0, total
  end

  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    val = true if user.cart.id == id
    val
  end

  def self.name_self
    "Cart"
  end

  def name
    name_self
  end

  def num_items
    p_manifests.length + m_manifests.length
  end

  def has_items?
    num_items > 0
  end

  def get_text
    "Your cart has #{num_items} items waiting to be purchased!"
  end

end
