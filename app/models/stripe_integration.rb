class StripeIntegration < ApplicationRecord
  belongs_to :group

    def allowed?(user)
      val = false
      val = true if user.group.elevation == 9
      val = true if user.group_id == group_id
      val
    end

    def self.name_self
      "Stripe Integration Object"
    end
end
