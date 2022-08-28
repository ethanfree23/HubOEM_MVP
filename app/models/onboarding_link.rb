class OnboardingLink < ApplicationRecord
  belongs_to :onboarding

  validate :valid_link, on: :create
  validate :unique, on: :create

  def object
    ObjectLink.object_from_link(obj_type,obj_id)
  end

  def name_self
    'OnboardingLink'
  end

  def valid_link
    errors.add(:obj_id, :invalid, message: ' is invalid.') if ObjectLink.object_from_link(obj_type,obj_id).nil?
  end

  def unique
    errors.add(:id, :duplicate, message: ' already linked.') if OnboardingLink.linked?(onboarding_id,obj_type,obj_id)
  end

  def self.linked?(onboarding_id,obj_type,obj_id)
    OnboardingLink.where(onboarding_id:onboarding_id,obj_type:obj_type,obj_id:obj_id).length.positive?
  end

  def self.name_self
    return 'Onboarding Link'
  end


end
