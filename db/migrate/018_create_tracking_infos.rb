class CreateTrackingInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :tracking_infos do |t|
      t.belongs_to :order
      t.string :tracking

      t.datetime :estimated_delivery_date

      t.timestamps
    end
  end
end
