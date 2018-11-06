class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :nickname
      t.boolean :active, default: true
      t.boolean :default_add, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
