class UpdateMomentsStructure < ActiveRecord::Migration[7.0]
  def change
    # Remove existing columns that are no longer needed
    remove_column :moments, :category, :integer

    # Add new columns for period type
    add_column :moments, :period_type, :string
    add_column :moments, :year, :integer
    add_column :moments, :period_number, :integer  # For quarter number or semester number

    # Add an index for faster queries
    add_index :moments, [ :period_type, :year, :period_number ], unique: true
  end
end
