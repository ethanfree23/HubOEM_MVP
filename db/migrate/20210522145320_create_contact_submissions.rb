class CreateContactSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_table :contact_submissions do |t|
      t.string :email
      t.string :content

      t.timestamps
    end
  end
end
