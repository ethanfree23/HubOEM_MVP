class Machine < ApplicationRecord
  belongs_to :group
  belongs_to :manufacturer, :class_name => "Group"
  belongs_to :brand, :class_name => "Group"

  has_many :parts_in_machines, dependent: :delete_all
  has_many :parts, through: :parts_in_machines

  has_many :m_instances

  has_many :document_links, as: :obj
  has_many :linked_documents, through: :document_links, source: :document
  has_many :part_documents, through: :parts, source: :documents

  def documents
    (part_documents + linked_documents).uniq
  end

  def self.find_by_group(current_user)
    if current_user.group.elevation == 9
      return Machine.all
    end
    current_user.machines
  end

  def pims
    parts_in_machines
  end

  def get_related_docs
    (documents + part_documents).uniq
  end

  def fields
    [:manufacturer,:name,:description,:group_id]
  end

  def allowed?(user)
    return true if user.group.elevation == 9
    return true if user.group_id == group_id
    m_instances.each do |mi|
      return true if mi.group_id == user.group_id
    end
    return false
    rescue NoMethodError
      false
  end


  def self.name_self
    "Machine"
  end

end
