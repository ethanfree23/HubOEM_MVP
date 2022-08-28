class Message < ApplicationRecord
  has_one_attached :msg_file
  belongs_to :conversation
  belongs_to :sender   , :class_name => "User"

  validates :content, presence: true, allow_blank: false, unless: ->(message){message.msg_file.present?}
  validates :msg_file, presence: true, allow_blank: false, unless: ->(message){message.content.present?}

  def self.name_self
    "Message"
  end

  def name
    self.class.name_self
  end

  def get_text
    if msg_file.present?
      "#{content} (File attached)"
    else
      content
    end
  end
end
