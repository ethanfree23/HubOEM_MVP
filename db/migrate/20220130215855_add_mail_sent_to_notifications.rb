class AddMailSentToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :mail_sent, :boolean, default: false
  end
end
