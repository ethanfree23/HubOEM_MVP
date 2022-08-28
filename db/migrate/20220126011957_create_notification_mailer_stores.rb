class CreateNotificationMailerStores < ActiveRecord::Migration[7.0]
  def change
    create_table :notification_mailer_stores do |t|
      t.belongs_to :notification, null: false
      t.boolean :sent, null: false
      t.integer :bulk_sent_id, null: false, default: -1
      t.timestamps
    end
  end
end
