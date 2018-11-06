require 'rails_helper'

RSpec.describe 'Create Order' do
  context 'as a registered user' do
    it 'allows me to check out and create an order' do
      merchant = create(:merchant)
      address_merchant = create(:address, user: merchant, default_add: true)
      active_item = create(:item, user: merchant)
      inactive_item = create(:inactive_item, name: 'inactive item 1')
      user = create(:user)
      address_user = create(:address, user: user, default_add: true)


      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      item_1, item_2 = create_list(:item, 2, user: merchant)
      visit item_path(item_1)
      click_button("Add to Cart")
      visit item_path(item_2)
      click_button("Add to Cart")

      visit carts_path
      click_button "Check out"
      expect(current_path).to eq(profile_orders_path)
      order = Order.last

      within("#order-#{order.id}") do
        order.order_items.each do |o_item|
          within("#order-details-#{order.id}") do
            expect(page).to have_content(o_item.item.name)
          end
        end
      end
      expect(page).to have_content("Cart: 0")
    end

    it 'should create the order with the default address' do
      merchant = create(:merchant)
      address_merchant = create(:address, user: merchant, default_add: true)
      active_item = create(:item, user: merchant)
      inactive_item = create(:inactive_item, name: 'inactive item 1')
      user = create(:user)
      address_user = create(:address, user: user, default_add: true)


      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      item_1, item_2 = create_list(:item, 2, user: merchant)
      visit item_path(item_1)
      click_button("Add to Cart")
      visit item_path(item_2)
      click_button("Add to Cart")

      visit carts_path
      click_button "Check out"

      order = Order.last


      within("#order-address-#{order.id}") do
        expect(page).to have_content(address_user.nickname)
        expect(page).to have_content(address_user.street)
        expect(page).to have_content(address_user.city)
        expect(page).to have_content(address_user.state)
        expect(page).to have_content(address_user.zip)
      end

    end

    it 'should create the order with a different address' do
      merchant = create(:merchant)
      address_merchant = create(:address, user: merchant, default_add: true)
      active_item = create(:item, user: merchant)
      inactive_item = create(:inactive_item, name: 'inactive item 1')
      user = create(:user)
      address_user = create(:address, user: user, default_add: true, nickname: "home")
      address_user_2 = create(:address, user: user, nickname: "work")


      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      item_1, item_2 = create_list(:item, 2, user: merchant)
      visit item_path(item_1)
      click_button("Add to Cart")
      visit item_path(item_2)
      click_button("Add to Cart")

      visit carts_path
      choose(option: address_user_2.id)
      click_button "Check out"
      order = Order.last


      within("#order-address-#{order.id}") do
        expect(page).to have_content(address_user_2.nickname)
        expect(page).to have_content(address_user_2.street)
        expect(page).to have_content(address_user_2.city)
        expect(page).to have_content(address_user_2.state)
        expect(page).to have_content(address_user_2.zip)
      end

    end
    it 'allows me to cancel a pending order' do
      merchant = create(:merchant)
      user = create(:user)
      item_1, item_2 = create_list(:item, 2, user: merchant)
      address = create(:address, user: user)

      order_1 = create(:order, user: user, address: address)
      create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit profile_orders_path
      expect(page).to_not have_content("no orders yet")

      within("#order-#{order_1.id}") do
        expect(page).to have_content("pending")
        click_button 'Cancel Order'
      end
      expect(current_path).to eq(profile_orders_path)
      within("#order-#{order_1.id}") do
        expect(page).to have_content("cancelled")
      end
    end
  end
  context 'as a merchant' do
    it 'should mark a whole order as fulfilled when the last merchant fulfills their portions' do
      merchant = create(:merchant)
      user = create(:user)
      address_user = create(:address, user: user, default_add: true)
      item_1 = create(:item, user: merchant)
      order_1 = create(:order, user: user, address: address_user)
      oi_1 = create(:order_item, order: order_1, item: item_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

      visit order_path(order_1)

      within "#orderitem-details-#{oi_1.id}" do
        expect(page).to have_content(item_1.name)
        click_button "fulfill item"
      end

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit order_path(order_1)

      expect(page).to have_content("Status: completed")
      expect(page).to_not have_button('Cancel Order')
    end
  end
  context 'mixed user login workflow' do
    it 'a cancelled order with fulfilled items puts inventory back' do
      merchant = create(:merchant)
      user = create(:user)
      address = create(:address, user: user, default_add: true)
      item_1, item_2 = create_list(:item, 2, user: merchant)

      order_1 = create(:order, user: user, address: address)
      oi_1 = create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)

      # as a merchant, fulfill part of an order and verify
      # that inventory level has changed
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)
      old_inventory = item_1.inventory

      visit order_path(order_1)

      within "#orderitem-details-#{oi_1.id}" do
        expect(page).to have_content(item_1.name)
        click_button "fulfill item"
      end
      item_check = Item.find(item_1.id)
      expect(item_check.inventory).to_not eq(old_inventory)

      # now, as a user, cancel that entire order and verify
      # that inventory is restored
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit orders_path
      within("#order-#{order_1.id}") do
        click_button 'Cancel Order'
      end

      item_check = Item.find(item_1.id)
      expect(item_check.inventory).to eq(old_inventory)
    end
  end
end
