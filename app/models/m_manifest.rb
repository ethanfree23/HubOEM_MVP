class MManifest < ApplicationRecord
  belongs_to :m_instance
  belongs_to :order, optional: true
  belongs_to :cart, optional: true


  has_one :machine, through: :m_instance
  has_one :group, through: :machine

  def self.name_self
    "Machine Manifest"
  end

  def name
    self.class.name_self
  end
end
