class MInstance < ApplicationRecord

  belongs_to :group, optional:true
  belongs_to :manufacturer, class_name: "Group", optional: true
  belongs_to :machine, optional: true

  has_many :p_instances, dependent: :delete_all
  has_many :parts, through: :p_instances
  belongs_to :facility, optional: true

  validate :validate_machine

  after_create :propagate_p_instances

  has_many :document_links, as: :obj
  has_many :linked_documents, through: :document_links, source: :document
  has_many :machine_documents, through: :machine, source: :linked_documents
  has_many :part_documents, through: :parts, source: :documents

  def documents
    (linked_documents + machine_documents + part_documents).uniq
  end
  
  def propagate_p_instances
    return unless machine.present?
    
    # If it saved, we want to auto-propogate parts based on the machine and
    # its parts.
    machine.parts.each do |part|
      p = PInstance.new
      p.serviceDate = DateTime.now
      p.part_id = part.id
      p.m_instance_id = id
      # THERE HAS TO BE A BETTER WAY THAN THIS.
      # Basically machines are linked to parts through a joined table, parts in machines.
      # That table has the quantity. So we have to get the index of the part, then access
      # the quantity from that table. There is probably a join we can use. If you're reading
      # this, I'm leaving it for my sanity's sake. Have fun.
      p.quantity = machine.parts_in_machines[machine.parts.index(part)].quantity
      p.save!
    end
  end

  def self.find_by_group(user)
    if user.elevation == 9
      return MInstance.all
    end
    return user.get_mis
  end

  def get_related_docs
    docs = documents + machine_documents + part_documents
    docs.uniq
  end

  def name
    if read_attribute(:name)
      read_attribute(:name)
    elsif machine
      machine.name
    else
      ""
    end
  end

  def self.name_self
    "Machine Instance"
  end

  def fields
    [:serial,:installDate]
  end

  def allowed?(user)
    val = false
    val = true if user.group.elevation == 9
    val = true if user.group_id == group_id
    vae = true if m_manufacturer.id == user.group.id
    val = true if user.group_id == machine.group_id if machine.present?
    val
    rescue NoMethodError
      false
  end

  def set_onboarding
    MInstance.update(id,installDate:DateTime.now)
  end

  def m_name
    begin
      if name.present?
        name + serial.to_s
      else
        machine.name + serial.to_s
      end
    rescue
      "ERROR NAME NOT FOUND. CONTACT AN ADMIN"
    end
  end

  def base_name
    begin
      if name.present?
        name
      else
        machine.name
      end
    rescue
      "ERROR NAME NOT FOUND. CONTACT AN ADMIN"
    end
  end

  def m_manufacturer
    if manufacturer.present?
      manufacturer
    else
      machine.manufacturer
    end
  end

  def m_description
    if machine.present?
      machine.description
    else
      description
    end
  end

  def validate_machine
    logger.warn self.as_json
    unless machine_id.present?
      validate_name
      validate_serial
      validate_manufacturer_id
    end
  end

  def validate_name
    unless name.present?
      errors.add(:name, :invalid, message: " or machine must be present.")
    end
  end

  def validate_serial
    unless serial.present?
      errors.add(:serial, :invalid, message: " must be present.")
    end
  end

  def validate_manufacturer_id
    unless manufacturer_id.present?
      errors.add(:manufacturer_id, :invalid, message: " or machine must be present.")
    end
  end

end
