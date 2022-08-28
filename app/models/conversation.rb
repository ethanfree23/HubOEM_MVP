class Conversation < ApplicationRecord
  belongs_to :sender  , class_name: 'Group'
  belongs_to :receiver, class_name: 'Group'

  validates :topic_id, presence:true, length: { minimum: 1 }

  has_many :messages, dependent: :destroy

  validate :valid_link, on: :create
  validate :unique, on: :create

  has_many :messages

  def topic_obj
    ObjectLink.object_from_link(topic,topic_id)
  end

  def self.find_by_group(current_user)
    group_id = current_user.group.id
    return Conversation.where(sender_id: group_id) + Conversation.where(receiver_id: group_id)
  end

  def self.name_self
    'Conversation'
  end

  def name
    "#{sender.name} to #{receiver.name} RE: #{topic_obj.name}"
  end

  def unread?(current_user)
    g_id = current_user.group.id
    ms = messages.sort_by{|e| e[:created_at]}
    ms.each do |m|
      return true if (m.read_status.zero? and g_id != m.sender_id)
    end
    return false
  end

  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    val = true if user.group_id == sender_id
    val = true if user.group_id == receiver_id
    val
    rescue NoMethodError
      false
  end

  def valid_link
    errors.add(:topic_id, :invalid, message: ' is invalid.') if ObjectLink.object_from_link(topic,topic_id).nil?
  end

  def unique
    if Conversation.where(sender_id: sender_id,
                          receiver_id: receiver_id,
                          topic: topic,
                          topic_id: topic_id ).length.positive?
      errors.add(:topic_id, :duplicate, message: 'not unique.')
    end
  end

end
