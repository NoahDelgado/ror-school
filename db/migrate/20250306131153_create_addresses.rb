class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :zip
      t.string :town
      t.string :street
      t.string :number

      t.timestamps
    end
  end
end
