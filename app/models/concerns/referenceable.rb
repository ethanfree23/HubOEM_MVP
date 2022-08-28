module Referenceable
  extend ActiveSupport::Concern
  included do
    has_many :line_item_instances, as: :referenceable
  end
end
