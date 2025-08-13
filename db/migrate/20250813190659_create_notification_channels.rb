class CreateNotificationChannels < ActiveRecord::Migration[7.1]
  def change
    create_table :notification_channels do |t|
      t.string :channel_type
      t.text :config
      t.boolean :active

      t.timestamps
    end
  end
end
