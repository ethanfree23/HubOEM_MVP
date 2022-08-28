class NotificationMailerStore < ApplicationRecord
  belongs_to :notification

  def allowed?(user)
    if user.elevation == 9
      return true
    elsif user.group_id == notification.group_id
      return true
    end

    false
  end
end
