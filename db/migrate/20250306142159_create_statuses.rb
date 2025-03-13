class CreateStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :statuses do |t|
      t.string :slug
      t.string :title

      t.timestamps
    end
  end
end
