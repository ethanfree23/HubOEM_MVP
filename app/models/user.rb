class User < ApplicationRecord
  before_create :set_default_group

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  belongs_to :group, optional: true
  has_many :documents, through: :group
  has_many :facilities, through: :group

  has_many :machines, through: :group
  has_many :parts, through: :group

  has_one :stripe_integration, through: :group

  has_many :m_instances, through: :group
  has_many :p_instances, through: :m_instances

  has_many :cpg_machines, through: :m_instances, class_name: "Machine", source: :machines
  has_many :cpg_parts, through: :p_instances, class_name: "Part"

  has_many :oem_m_instances, through: :machines, class_name: "MInstance", source: :m_instances
  has_many :oem_p_instances, through: :oem_m_instances, class_name: "PInstances"

  has_many :part_quotes, through: :group

  has_one_attached :avatar
  validates :avatar, content_type: ['image/png', 'image/jpg', 'image/jpeg'],
            size: { less_than: 10.megabytes , message: 'Logo too large.' }

  def get_mis
    m_instances + oem_m_instances
  end

  def assets
    assets = []
    case elevation
    when 9
      return Machine.all + Part.all + MInstance.all
    when 1
      return parts + machines + oem_m_instances
    when 2
      return cpg_parts + cpg_machines + m_instances
    else
      assets
    end
    assets
  end

  def assets_with_documents
    results = []
    assets.each do |asset|
      if asset.is_a? PInstance
        asset = asset.part
      end
      if asset.documents.present?
        results << asset
      end
    end
    results.uniq
  end

  def oem_orders
    group.oem_orders
  end

  def cpg_orders
    group.cpg_orders
  end

  def orders
    (oem_orders+cpg_orders).uniq
  end

  def personal_messages
    pms = []
    Conversation.where(sender_id:0).each do |c|
      c.messages.each do |m|
        if m.sender_id == current_user.id
          pms << c
          break
        end
      end
    end
    pms
  end

  def unread_messages
    conversations.count
  end

  def set_default_group
    self.group ||= Group.find(0)
  end

  def self.name_self
    "User"
  end

  def name
    firstname.nil? ? email : firstname
  end

  def num_unread
    get_unread.length
  end

  def get_unread
    ms = []
    get_conversations.each do |c|
      ms << c if c.unread?(self)
    end
    ms
  end

  def get_conversations
    conversations.sort_by{|e| e[:updated_at]}
  end

  def conversations
    Conversation.where(sender_id: group_id).or(Conversation.where(receiver_id: group_id))
  end

  def get_parts
    case elevation
    when 9
      return Part.all
    when 1
      return current_user.parts
    when 2
      return cpg_parts
    else
      return []
    end
  end

  def get_uniq_pis
    PInstance.all.joins("
      INNER JOIN m_instances ON p_instances.m_instance_id = m_instances.id
      WHERE m_instances.group_id = #{group_id}
      ").uniq
  end

  def search(query)
    # Things to search for:
    # Name: Part, Machine, Document, Group
    # Description: Part, Machine
    # ID: Order
    # QRHash: Part
    results = []
    searchable = {"name"=>[Part,Machine,Document,Group],"description"=>[Part,Machine],"id"=>[Order],"qrhash"=>[Part],"part_number"=>[Part],"warehouse_location"=>[Part],"vendor_name"=>[Part],"vendor_number"=>[Part],"mfr_string"=>[Part]}
    searchable.keys.each do |key|
      searchable[key].each do |thing|
        # Polymorphism yay
        thing.where(key + " like ?", "%#{query}%").each do |result|
          results << result if result.allowed?(self)
        end
      end
    end
    results.uniq
  end

  def cart
    group.cart
  end

  def elevation
    group.elevation
  end

  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    val = true if user.group_id == group_id
    val
  end

  def type
    group.type
  end

  def unread_notifications
    group.unread_notifications
  end

  def update_password_with_password(params, *options)
    current_password = params.delete(:current_password)

    result = if valid_password?(current_password)
               update_attributes(params, *options)
              else
                self.assign_attributes(params, *options)
                self.valid?
                self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                false
              end
    clean_up_passwords
    result
  end

  def parse_subscription_status
    JSON.parse subscription_status
  end

  def query_subscription_status(type)
    status = parse_subscription_status
    return false if status['unsubscribe']
    return true if status.empty?
    return status[type] if status.keys.include? type

    true
  end

  def marketing_subscription_status
    query_subscription_status 'marketing'
  end

  def digest_subscription_status
    query_subscription_status 'digest'
  end

  def notification_subscription_status
    query_subscription_status 'notificaiton'
  end

  def order_subscription_status
    query_subscription_status 'order'
  end

  def visible_documents
    group.visible_documents
  end

end
