class Document < ApplicationRecord
  has_one_attached :file
  validates_presence_of :name
  validates :file,
            content_type: { in: %w[application/pdf
                                   image/jpg
                                   image/jpeg
                                   image/png
                                   application/sldprt
                                   application/prt
                                   application/sldasm
                                   application/asm],
                            message: 'is not a an accepted type' },
            size: { less_than: 400.megabytes, message: 'is not given between size' },
            unless: ->(document) { document.forge_status.present? }
  validates :file, presence: true,
                   unless: ->(document) { document.forge_status.present? }

  belongs_to :group
  has_many :document_links, dependent: :destroy

  after_create :post_process

  def self.part_documents(user)
    Document.all.joins("
      INNER JOIN document_links ON document_links.obj_type = 5 and documents.id = document_links.document_id
      INNER JOIN parts ON parts.id = document_links.obj_id
      WHERE parts.group_id = #{user.group_id}
      ")
  end

  def self.m_instance_documents(user)
    Document.all.joins("
      INNER JOIN document_links ON document_links.obj_type = 4 and documents.id = document_links.document_id
      INNER JOIN m_instances ON m_instances.id = document_links.obj_id
      WHERE m_instances.group_id = #{user.group_id}
      ") +
      Document.all.joins("
        INNER JOIN document_links ON document_links.obj_type = 3 and documents.id = document_links.document_id
        INNER JOIN machines ON machines.id = document_links.obj_id
        INNER JOIN m_instances ON m_instances.machine_id = machines.id
        WHERE m_instances.group_id = #{user.group_id}
        ") +
      Document.all.joins("
        INNER JOIN document_links ON document_links.obj_type = 5 and documents.id = document_links.document_id
        INNER JOIN parts ON parts.id = document_links.obj_id
        INNER JOIN p_instances ON p_instances.part_id = parts.id
        INNER JOIN m_instances ON m_instances.id = p_instances.m_instance_id
        WHERE m_instances.group_id = #{user.group_id}
        ")
  end

  def self.machine_documents(user)
    Document.all.joins("
      INNER JOIN document_links ON document_links.obj_type = 3 and documents.id = document_links.document_id
      INNER JOIN machines ON machines.id = machines.obj_id
      WHERE machines.group_id = #{user.group_id}
      ") +
      Document.all.joins("
        INNER JOIN document_links ON document_links.obj_type = 5 and documents.id = document_links.document_id
        INNER JOIN parts ON parts.id = document_links.obj_id
        INNER JOIN parts_in_machines ON parts_in_machines.part_id = parts.id
        INNER JOIN machines on machines.id = parts_in_machines.machine_id
        WHERE machines.group_id = #{user.group_id}
        ")
  end

  def allowed?(user)
    if user.elevation == 9
      return true
    end
    # This line causes preformance issues.
    Document.visible_documents(user).include?(Document.find(id))
    # return true
  end

  def test_user(user)
    assets = user.assets
    document_links.all do |dl|
      return true if assets.include?(dl.object)
    end
    false
  end

  def self.find_by_group(user)
    user.documents
  end

  # I think this is pretty self explanitory, but this is to tell if a given obj
  #   and this document aren't already linked.
  def linked?(obj)
    obj_type,obj_id = ObjectLink.link_from_object(obj)
    DocumentLink.where(document_id:id,obj_type:obj_type,obj_id:obj_id).length > 0
  end

  def self.name_self
    'Document'
  end

  def description
    ''
  end

  def post_process

  end

  def self.visible_documents(current_user)
    current_user.visible_documents
  end

  private

end
