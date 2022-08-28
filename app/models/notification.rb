class Notification < ApplicationRecord
  belongs_to :group
  after_create :send_email
  #after_create :create_mailer_store

  validate :valid_link, on: :create
  validate :valid_type, on: :create

  $NOTIFICATION_TYPES = {
    # User
    1 => {
      1 => 'New user signed up.',
      2 => 'User requested to join group.',
      3 => 'User account deleted.',
      4 => 'User Started a password change request.',
      5 => 'User Password change request was completed.'
    },
    # Group
    2 => {
      1 => 'User joined your group.'
    },
    # Machine
    3 => {
      1 => '',
      3 => 'Bulk upload of parts complete on '
    },
    # MInstance
    4 => {
      1 => 'OEM assigned you a new machine: ',
      2 => 'OEM assigned a new machine, ',
      3 => 'Bulk upload of parts complete on '
    },
    # Part
    5 => {
      1 => '',
      2 => 'This is a test!'
    },
    # PInstance
    6 => {
      1 => 'OEM added a document to ',
      2 => 'OEM assigned a new part, ',
      3 => 'OEM provided a quote on part '

    },
    # Order
    7 => {
      1 => 'New order: ',
      2 => '',
      3 => 'OEM Uploaded shipping information on ',
      4 => 'Payment received on order ',
      5 => 'A Line Item was added on order ',
      6 => 'A Line Item was removed on order '

    },
    # Document
    8 => {
    },
    #   9=>Conversation
    9 => {
      1 => 'New message in conversation ',
      2 => 'New message in conversation ',
      9 => 'New message in conversation '

    },
    #   10=>Feedback
    10 => {
      1 => 'New feedback from '

    },
    #   11=>Onboarding
    11 => {
      1 => 'A new customer has completed your onboarding, '

    },
    # 12 => Payment
    12 => {
      1 => 'Payment method rejected or bad connection. Please review and contact an admin. ',
      2 => 'Payment declined or rejected. Please review your order. ',
      3 => 'Payment accepted. ',
      4 => 'Payment received on order ',
      5 => ''
    },
    13 => {
      1 => 'This is just a test!'
    }

  }

  def object
    ObjectLink.object_from_link(obj_type,obj_id)
  end

  def allowed?(user)
    if user.elevation == 9
      return true
    elsif user.group_id == group_id
      return true
    end

    false
  end

  def self.unread(object)
    case object
    when User
      Notification.where(group_id: object.group_id, read: false)
    when Group
      Notification.where(group_id: object.id, read: false)
    end
  end

  def self.recent(object)
    now = Time.now
    case object
    when User
      Notification.where(group_id: object.group_id, updated_at: (now - 24.hours)..now)
    when Group
      Notification.where(group_id: object.id, created_at: (now - 24.hours)..now)
    end
  end

  def get_text
    begin
      $NOTIFICATION_TYPES[obj_type][notification_type] + object.name
    rescue
      'Object deleted or other error.'
    end
  end

  def mark_as_read
    read = true
    self.save!
  end

  private

  def send_email
    # now for each user in the group, send the mail if they have opted in to recieve email updates
    # group_users = User.all.select { |i| i.group_id == group_id }
    # NotificationMailer.order_created_email(order, current_user)
  end

  def create_mailer_store
    mailer_store = NotificationMailerStore.new
    mailer_store.notification_id = id
    mailer_store.sent = false
    mailer_store.save!
  end

  def valid_link
    errors.add(:obj_id, :invalid, message: ' is invalid.') if ObjectLink.object_from_link(obj_type,obj_id).nil?
  end

  def valid_type
    if $NOTIFICATION_TYPES[obj_type][notification_type].nil?
      errors.add(:notification_type, :invalid, message: ' notification has invalid text.')
    end
  end

  def self.name_self
    'Notification'
  end

end
