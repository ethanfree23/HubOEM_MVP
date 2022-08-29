class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.belongs_to :conversation

      t.integer :sender_id
      t.integer :read_status
      t.text :content

      t.timestamps
    end
  end
end
