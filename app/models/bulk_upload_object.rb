class BulkUploadObject < ApplicationRecord

  has_one_attached :file
  # validates size: { less_than: 1.megabytes , message: 'File too large.' }
  # :file, content_type: ['application/vnd.ms-excel',],


  validate :valid_link, :on => :create

  def execute
    BulkXlsImportJob.perform_later(self)
  end

  def file_path
    ActiveStorage::Blob.service.path_for(file.key)
  end

  def valid_link
    errors.add(:obj_id, :invalid, message: " is invalid.") if ObjectLink.object_from_link(obj_type,obj_id).nil?
  end

end
