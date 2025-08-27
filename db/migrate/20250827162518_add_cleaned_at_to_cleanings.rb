class AddCleanedAtToCleanings < ActiveRecord::Migration[7.1]
  def change
    add_column :cleanings, :cleaned_at, :datetime
  end
end
