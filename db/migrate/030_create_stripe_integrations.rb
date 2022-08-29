class CreateStripeIntegrations < ActiveRecord::Migration[6.0]
  def change
    create_table :stripe_integrations do |t|
      t.belongs_to :group
      t.text :stripe_uuid
      t.text :description

      t.timestamps
    end
  end
end
