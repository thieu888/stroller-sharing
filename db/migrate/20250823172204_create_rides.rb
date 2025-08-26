class CreateRides < ActiveRecord::Migration[7.1]
  def change
    create_table :rides do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stroller, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :start_lat
      t.decimal :start_lng
      t.decimal :end_lat
      t.decimal :end_lng
      t.decimal :cost
      t.string :status

      t.timestamps
    end
  end
end
