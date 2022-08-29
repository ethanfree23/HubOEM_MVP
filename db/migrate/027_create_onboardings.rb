class CreateOnboardings < ActiveRecord::Migration[6.0]
  def change
    create_table :onboardings do |t|
      t.belongs_to :user

      t.integer :creator_id
      t.string :token
      t.datetime :expiration_date
      t.boolean :consumed
      t.string :email
      t.text :custom_email_text

      t.timestamps
    end
  end
end
