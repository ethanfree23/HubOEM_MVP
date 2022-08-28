class Revision < ApplicationRecord
  belongs_to :user
  belongs_to :group

  def object
    ObjectLink.object_from_link object_type, object_id
  end

  def type_text
    texts = {1=>"Creation",2=>"Modification",3=>"Delete"}
    texts[modification_type]
  end

  def allowed(current_user)
    if current_user.elevation == 9
      true
    elsif current_user.group == revision.group
      true
    end
    false
  end

  def self.name_self
    "Revision"
  end

end
