class CreateAlerts < ActiveRecord::Migration[7.1]
  def change
    create_table :alerts do |t|
      t.string :symbol
      t.decimal :threshold_price
      t.string :direction
      t.boolean :active
      t.text :notification_channels

      t.timestamps
    end
  end
end
