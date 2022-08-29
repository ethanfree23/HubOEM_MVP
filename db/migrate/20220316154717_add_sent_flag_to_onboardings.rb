class AddSentFlagToOnboardings < ActiveRecord::Migration[6.0]
  def change
    add_column :onboardings, :sent, :boolean, default:false
  end
end
