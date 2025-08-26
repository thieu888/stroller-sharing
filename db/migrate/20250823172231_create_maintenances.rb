class CreateMaintenances < ActiveRecord::Migration[7.1]
  def change
    create_table :maintenances do |t|
      t.references :stroller, null: false, foreign_key: true
      t.references :reported_by, null: false, foreign_key: { to_table: :users }
      t.text :issue_description
      t.string :status
      t.datetime :resolved_at

      t.timestamps
    end
  end
end
