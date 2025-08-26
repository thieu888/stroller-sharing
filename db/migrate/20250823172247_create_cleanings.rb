class CreateCleanings < ActiveRecord::Migration[7.1]
  def change
    create_table :cleanings do |t|
      t.references :stroller, null: false, foreign_key: true
      t.references :cleaned_by, null: false, foreign_key: { to_table: :users }
      t.string :cleaning_type
      t.text :notes
      t.datetime :next_due

      t.timestamps
    end
  end
end
