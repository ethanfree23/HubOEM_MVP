class Onboarding < ApplicationRecord
  belongs_to :user, optional: true
  has_many :onboarding_links, dependent: :delete_all

  has_one :creator, :class_name => "Group"

  after_create :generate_token
  after_create :set_consumed

  before_destroy :destroy_objects

  def link_objects(objs)
    objs.each do |obj|
      if creator_id == obj.group.id
        obj_type,obj_id = ObjectLink.link_from_object(obj)
        OnboardingLink.new(onboarding_id:id, obj_type:obj_type, obj_id:obj_id)
      else
        # Put an error here.
      end
    end
  end

  def set_consumed
    Onboarding.update(id,consumed:false)
  end

  def consumed?
    consumed == true
  end

  def objects
    objs = []
    onboarding_links.each do |link|
      objs << link.object
    end
    objs
  end

  def pretty_objects
    onboarding_links.map { |ol| "#{ol.object.name} : #{ol.serial}" }
  end

  def generate_token
    Onboarding.update(id,token:SecureRandom.uuid)
    send_email
  end

  def resend_email
    send_email
  end

  def email_sent?
    sent == true
  end

  def consume
    Onboarding.update(id,consumed:true)
    objects.each do |object|
      object.set_onboarding if object.is_a? MInstance
    end
  end

  def reserved?
    user.present?
  end

  def reserve(other_user)
    if not reserved? and other_user.elevation != 1 and other_user.elevation != 9
      Onboarding.update(id,user_id:other_user.id)
    else
        # raise an error
    end
  end

  def allowed?(current_user)
    if current_user.elevation==9
      return true
    elsif creator == current_user.group
      return true
    elsif reserved?
      return current_user == user
    elsif current_user.elevation == 0 or current_user.elevation == 2
      return true
    end
    false
  end

  def self.name_self
    return "Onboarding"
  end

  private
    def send_email
      SendOnboardingEmailJob.set(wait: 20.seconds).perform_later(creator_id, email, Onboarding.find(id).token)
      sent = true
    end

    def destroy_objects
      object_links.each do |ol|
        ol.object.destroy
      end
    end

end
