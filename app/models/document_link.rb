class DocumentLink < ApplicationRecord

  belongs_to :document
  belongs_to :obj, polymorphic: true

  validate :unique, :on => :create

  def self.link_object(document,object)
    a = DocumentLink.new
    a.obj = object
    a.document = document
    # NOTE, THIS RETURNS A LINK AND WOULD NEED TO BE SAVED.
    return a
  end

  def self.link_object_params(document,obj_type,obj_id)
    a = DocumentLink.new
    a.obj_type,a.obj_id = obj_type,obj_id
    a.document = document
    # NOTE, THIS RETURNS A LINK AND WOULD NEED TO BE SAVED.
    return a
  end

  def self.get_documents(object)
    object.documents
  end

  def object
    obj
  end

  def self.name_self
    "DocumentLink"
  end

  def valid_link
    if ObjectLink.object_from_link(obj_type,obj_id).nil?
      errors.add(:obj_id, :invalid, message: " is invalid.")
    end
  end

  def unique
    if DocumentLink.linked?(document_id,obj_type,obj_id)
      errors.add(:id, :duplicate, message: " already linked.")
    end
  end

  def self.linked?(document_id,obj_type,obj_id)
    DocumentLink.where(document_id:document_id,obj_type:obj_type,obj_id:obj_id).length > 0
  end


end
