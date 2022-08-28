class TrackingInfo < ApplicationRecord
  belongs_to :order
  def self.name_self
    "Tracking Information"
  end
end
