require 'factory_bot_rails'

include FactoryBot::Syntax::Methods

OrderItem.destroy_all
Order.destroy_all
Item.destroy_all
User.destroy_all

admin = create(:admin)
user_1, user_2 = create_list(:user, 2)
merchant_1 = create(:merchant)

merchant_2, merchant_3, merchant_4 = create_list(:merchant, 3)

admin_address_1 = create(:address, user: admin, default_add: true)
user_address_1 = create(:address, user: user_1, default_add: true)
user_address_2 = create(:address, user: user_1, default_add: false)
user_address_3 = create(:address, user: user_2, default_add: false)
user_address_4 = create(:address, user: user_2, default_add: true)
merchant_address_1 = create(:address, user: merchant_1, default_add: true)
merchant_address_2 = create(:address, user: merchant_2, default_add: true)
merchant_address_3= create(:address, user: merchant_3, default_add: true)

item_1 = create(:item, user: merchant_1)
item_2 = create(:item, user: merchant_2)
item_3 = create(:item, user: merchant_3)
item_4 = create(:item, user: merchant_4)
create_list(:item, 10, user: merchant_1)

order = create(:completed_order, user: user_1, address: user_address_1)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1)

order = create(:completed_order, user: user_1, address: user_address_1)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)

order = create(:completed_order, user: user_1, address: user_address_1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1)

order = create(:completed_order, user: user_1, address: user_address_1)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)

order = create(:completed_order, user: user_2, address: user_address_2)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1)

order = create(:completed_order, user: user_2, address: user_address_2)
create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1)
