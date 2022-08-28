class CreateConversations < ActiveRecord::Migration[6.0]
  def change
    create_table :conversations do |t|
      t.integer :topic
      t.integer :topic_id
      t.string :topic_text
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
  end
end
