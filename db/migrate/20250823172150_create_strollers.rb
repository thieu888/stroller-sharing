class CreateStrollers < ActiveRecord::Migration[7.1]
  def change
    create_table :strollers do |t|
      t.string :qr_code
      t.decimal :gps_lat
      t.decimal :gps_lng
      t.integer :battery_level
      t.string :status
      t.references :station, null: false, foreign_key: true

      t.timestamps
    end
  end
end
