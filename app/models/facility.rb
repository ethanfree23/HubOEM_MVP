class Facility < ApplicationRecord
  belongs_to :group
  validates_presence_of :name

  def self.find_by_group(current_user)
    if current_user.group.elevation == 9
      return Facility.all
    end
    current_user.facilities
  end

  def self.name_self
    "Facility"
  end

  # TODO: Add user elevation check here
  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    # return true if oem user and
    # TODO: add a condition that allows oems to only see facilities from the cpgs they have instances for
    val = true if user.group == facility.group #MInstance.where(["manufacturer_id = ?", user.group.id]).pluck(:id).include? id
    # return true if group id is in one of the groups m_instances
    val
    rescue NoMethodError
      false
  end

end
