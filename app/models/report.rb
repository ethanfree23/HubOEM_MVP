class Report < ApplicationRecord

  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    val = true if user.group_id == user.group_id
    val
  end

  def self.name_self
    return "Report"
  end
end
