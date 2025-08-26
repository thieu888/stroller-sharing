class CreateStations < ActiveRecord::Migration[7.1]
  def change
    create_table :stations do |t|
      t.string :name
      t.decimal :gps_lat
      t.decimal :gps_lng
      t.integer :capacity

      t.timestamps
    end
  end
end
