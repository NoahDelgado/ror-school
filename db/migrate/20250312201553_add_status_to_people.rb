class AddStatusToPeople < ActiveRecord::Migration[8.0]
  def change
    add_reference :people, :status, null: false, foreign_key: true
  end
end
