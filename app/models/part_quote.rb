class PartQuote < ApplicationRecord
  belongs_to :purchaser, class_name: 'Group'
  belongs_to :group
  belongs_to :part

  validates :amount, presence: true, on: :update
  validates :amount, numericality: { greater_than: 0 }, on: :update
  validates :shipping, presence: true, on: :update
  validates :shipping, numericality: { greater_than: 0 }, on: :update
  validates :duration, presence: true, on: :update
  validates :duration, numericality: { greater_than: -1 }, on: :update

  def open_quotes(group_id)
    PartQuote.where(amount: nil, duration: nil, group_id: group_id)
  end

  def self.valid_quote(object)
    group_quotes = PartQuote.where(part_id: object.part_id, purchaser_id: object.group.id)
                            .order(:quote_date)
                            .where
                            .not(amount: nil)
    group_quotes = group_quotes.limit(1)[0] if group_quotes.limit(1).present?

    return group_quotes if group_quotes.present? && ((DateTime.now - DateTime.parse(group_quotes.quote_date.to_s)).to_i < group_quotes.duration ||
      group_quotes.duration.zero?)

    apply_quotes = PartQuote.where(part_id: object.part_id, apply_all: true)
                            .order(:quote_date)
                            .where
                            .not(amount: nil)
    apply_quotes = apply_quotes.limit(1)[0] if apply_quotes.limit(1).present?

    return apply_quotes if apply_quotes.present? && ((DateTime.now - DateTime.parse(apply_quotes.quote_date.to_s)).to_i < apply_quotes.duration ||
      apply_quotes.duration.zero?)
  end

  def self.open_quotes(group)
    PartQuote.where(group_id: group.id, amount: nil)
  end

  def get_text
    "#{purchaser.name} has requested a quote for #{part.name}"
  end

end
