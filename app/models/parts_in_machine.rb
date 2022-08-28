class PartsInMachine < ApplicationRecord
  belongs_to :machine
  belongs_to :part

  def self.name_self
    "Parts in Machine"
  end
end
