class AddSubscriptionStatusToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.string :subscription_status
    end
  end
end
