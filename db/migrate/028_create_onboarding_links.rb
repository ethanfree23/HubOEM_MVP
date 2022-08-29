class CreateOnboardingLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :onboarding_links do |t|
      t.belongs_to :onboarding

      t.string :serial
      t.integer :obj_type
      t.integer :obj_id

      t.timestamps
    end
  end
end
