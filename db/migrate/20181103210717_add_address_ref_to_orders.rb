class AddAddressIdToOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :orders, :addresses, foreign_key: true
  end
end
