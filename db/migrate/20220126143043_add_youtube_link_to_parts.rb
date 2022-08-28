class AddYoutubeLinkToParts < ActiveRecord::Migration[7.0]
  def change
    change_table :parts do |t|
      t.string :video_url
    end
  end
end
