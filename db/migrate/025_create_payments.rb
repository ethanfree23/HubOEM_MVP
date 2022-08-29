class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.belongs_to :order, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :transaction_type
      t.boolean :accepted
      t.string :ref_num
      t.string :transaction_status
      t.string :response
      t.string :request

      t.timestamps
    end
  end
end
