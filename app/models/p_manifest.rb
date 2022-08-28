class PManifest < ApplicationRecord
  belongs_to :part
  belongs_to :order, optional: true
  belongs_to :cart, optional: true

  has_one :group, through: :part

  def self.name_self
    "Part Manifest"
  end

  def name
    part.name
  end

  def orderPricePerUnit
    if part.orderPricePerUnit.present? && part.orderPricePerUnit != 0
      part.orderPricePerUnit
    elsif PartQuote.valid_quote(self).present?
      PartQuote.valid_quote(self).amount
    else
      "Quote needed."
    end
  end

end
