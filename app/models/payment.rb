class Payment < ApplicationRecord
  # TODO: REMOVE THIS WHEN STABLE
  belongs_to :order, optional: true
  belongs_to :invoice
  belongs_to :user

  def self.name_self
    'Payment'
  end

  def name
    user.name + ' submitted payment on ' + order.name
  end

  def status
    if accepted.nil?
      'Pending'
    elsif accepted
      'Accepted'
    else
      'Declined'
    end
  end

  def accepted?
    accepted == true
  end

  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    val = true if user.group_id == order.group_id
    val
  end


end
