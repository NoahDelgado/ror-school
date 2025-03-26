class AddSoftDeleteToTables < ActiveRecord::Migration[7.0]
  def change
    # Add deleted_at to main tables
    add_column :school_classes, :deleted_at, :datetime
    add_column :courses, :deleted_at, :datetime
    add_column :grades, :deleted_at, :datetime
    add_column :examinations, :deleted_at, :datetime
    add_column :moments, :deleted_at, :datetime
    add_column :people, :deleted_at, :datetime

    # Add indexes for better query performance
    add_index :school_classes, :deleted_at
    add_index :courses, :deleted_at
    add_index :grades, :deleted_at
    add_index :examinations, :deleted_at
    add_index :moments, :deleted_at
    add_index :people, :deleted_at
  end
end
