class CreateMoments < ActiveRecord::Migration[8.0]
  def change
    create_table :moments do |t|
      t.string :uid
      t.integer :category
      t.datetime :start_at
      t.datetime :end_at

      t.timestamps
    end
  end
end
