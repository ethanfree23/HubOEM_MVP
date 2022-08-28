class Feedback < ApplicationRecord
  validates :title, presence: true, length: {minimum: 8}
  validates :body, presence: true, length: {minimum: 16}
  validates :user, presence: true

  def name
    user
  end

  def self.name_self
    "Feedback"
  end
end
