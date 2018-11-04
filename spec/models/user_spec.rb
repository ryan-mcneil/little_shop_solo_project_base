require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Relationships' do
    it { should have_many(:orders) }
    it { should have_many(:items) }
    it { should have_many(:addresses) }
  end

  describe 'Validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :name }
  end

  describe 'Class Methods' do
    it '.top_merchants(quantity)' do
      user = create(:user)
      address = create(:address, user: user, default_add: true)
      merchant_1, merchant_2, merchant_3, merchant_4 = create_list(:merchant, 4)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      item_3 = create(:item, user: merchant_3)
      item_4 = create(:item, user: merchant_4)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_1, price: 20000, quantity: 1)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2000, quantity: 1)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_3, price: 200000, quantity: 1)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_4, price: 200, quantity: 1)

      expect(User.top_merchants(4)).to eq([merchant_3, merchant_1, merchant_2, merchant_4])
    end
    it '.popular_merchants(quantity)' do
      user = create(:user)
      address = create(:address, user: user, default_add: true)
      merchant_1, merchant_2, merchant_3, merchant_4 = create_list(:merchant, 4)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)
      item_3 = create(:item, user: merchant_3)
      item_4 = create(:item, user: merchant_4)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_4, price: 4, quantity: 1)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_3, price: 3, quantity: 1)

      order = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1)
      create(:fulfilled_order_item, order: order, item: item_2, price: 2, quantity: 1)

      expect(User.popular_merchants(3)).to eq([merchant_2, merchant_1, merchant_3])
    end
    context 'merchants by speed' do
      before(:each) do
        user = create(:user)
        address = create(:address, user: user, default_add: true)

        @merchant_1, @merchant_2, @merchant_3, @merchant_4 = create_list(:merchant, 4)
        item_1 = create(:item, user: @merchant_1)
        item_2 = create(:item, user: @merchant_2)
        item_3 = create(:item, user: @merchant_3)
        item_4 = create(:item, user: @merchant_4)

        order = create(:order, user: user, address: address)
        create(:fulfilled_order_item, order: order, item: item_1, created_at: 1.year.ago)
        create(:fulfilled_order_item, order: order, item: item_2, created_at: 10.days.ago)
        create(:order_item, order: order, item: item_3, price: 3, quantity: 1)
        create(:fulfilled_order_item, order: order, item: item_4, created_at: 3.seconds.ago)
      end
      it '.fastest_merchants(quantity)' do
        expect(User.fastest_merchants(4)).to eq([@merchant_4, @merchant_2, @merchant_1, @merchant_3])
      end
      it '.slowest_merchants(quantity)' do
        expect(User.slowest_merchants(4)).to eq([@merchant_3, @merchant_1, @merchant_2, @merchant_4])
      end
    end
  end

  describe 'Instance Methods' do
    it '.merchant_items' do
      user = create(:user)
      address = create(:address, user: user, default_add: true)
      merchant = create(:merchant)
      item_1, item_2, item_3, item_4, item_5 = create_list(:item, 5, user: merchant)

      order_1 = create(:order, user: user, address: address)
      create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)

      order_2 = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order_2, item: item_2)
      create(:fulfilled_order_item, order: order_2, item: item_3)

      expect(merchant.merchant_orders).to eq([order_1, order_2])
    end
    it '.merchant_items(:pending)' do
      user = create(:user)
      address = create(:address, user: user, default_add: true)
      merchant = create(:merchant)
      item_1, item_2, item_3, item_4, item_5 = create_list(:item, 5, user: merchant)

      order_1 = create(:order, user: user, address: address)
      create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)

      order_2 = create(:completed_order, user: user, address: address)
      create(:fulfilled_order_item, order: order_2, item: item_2)
      create(:fulfilled_order_item, order: order_2, item: item_3)

      expect(merchant.merchant_orders(:pending)).to eq([order_1])
    end
    it '.merchant_for_order(order)' do
      user = create(:user)
      address = create(:address, user: user, default_add: true)
      merchant_1, merchant_2 = create_list(:merchant, 2)
      item_1, item_2 = create_list(:item, 5, user: merchant_1)
      item_3, item_4 = create_list(:item, 5, user: merchant_2)

      order_1 = create(:order, user: user, address: address)
      create(:order_item, order: order_1, item: item_1)
      create(:order_item, order: order_1, item: item_2)

      order_2 = create(:order, user: user, address: address)
      create(:order_item, order: order_2, item: item_3)
      create(:order_item, order: order_2, item: item_4)

      expect(merchant_1.merchant_for_order(order_1)).to eq(true)
      expect(merchant_1.merchant_for_order(order_2)).to eq(false)
    end
    it '.total_items_sold' do
      user = create(:user)
      address = create(:address, user: user, default_add: true)
      merchant_1, merchant_2 = create_list(:merchant, 2)
      item_1, item_2 = create_list(:item, 5, user: merchant_1)
      item_3, item_4 = create_list(:item, 5, user: merchant_2)

      order_1 = create(:completed_order, status: :completed, user: user, address: address)
      oi_1 = create(:fulfilled_order_item, order: order_1, item: item_1)
      oi_2 = create(:fulfilled_order_item, order: order_1, item: item_3)

      order_2 = create(:order, user: user, address: address)
      oi_3 = create(:fulfilled_order_item, order: order_2, item: item_2)
      oi_4 = create(:order_item, order: order_2, item: item_4)

      expect(merchant_1.total_items_sold).to eq(oi_1.quantity + oi_3.quantity)
      expect(merchant_2.total_items_sold).to eq(oi_2.quantity)
    end
    it '.total_inventory' do
      merchant = create(:merchant)
      item_1, item_2 = create_list(:item, 2, user: merchant)

      expect(merchant.total_inventory).to eq(item_1.inventory + item_2.inventory)
    end
    it '.top_3_shipping_states' do
      user_1 = create(:user)
      address_1 = create(:address, user: user_1, default_add: true, state: 'CO')
      user_2 = create(:user)
      address_2 = create(:address, user: user_2, default_add: true, state: 'CA')
      user_3 = create(:user)
      address_3 = create(:address, user: user_3, default_add: true, state: 'FL')
      user_4 = create(:user)
      address_4 = create(:address, user: user_4, default_add: true, state: 'NY')

      merchant = create(:merchant)
      item_1 = create(:item, user: merchant)

      # Colorado is 1st place
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      # California is 2nd place
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      # Sorry Florida
      order = create(:completed_order, user: user_3, address: address_3)
      create(:fulfilled_order_item, order: order, item: item_1)

      # NY is 3rd place
      order = create(:completed_order, user: user_4, address: address_4)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_4, address: address_4)
      create(:fulfilled_order_item, order: order, item: item_1)

      expect(merchant.top_3_shipping_states).to eq(['CO', 'CA', 'NY'])
    end
    it '.top_3_shipping_cities' do
      user_1 = create(:user)
      address_1 = create(:address, user: user_1, default_add: true, city: 'Denver')
      user_2 = create(:user)
      address_2 = create(:address, user: user_2, default_add: true, city: 'Houston')
      user_3 = create(:user)
      address_3 = create(:address, user: user_3, default_add: true, city: 'Ottawa')
      user_4 = create(:user)
      address_4 = create(:address, user: user_4, default_add: true, city: 'NYC')

      merchant = create(:merchant)
      item_1 = create(:item, user: merchant)

      # Denver is 2nd place
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      # Houston is 1st place
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      # Sorry Ottawa
      order = create(:completed_order, user: user_3, address: address_3)
      create(:fulfilled_order_item, order: order, item: item_1)
      # NYC is 3rd place
      order = create(:completed_order, user: user_4, address: address_4)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_4, address: address_4)
      create(:fulfilled_order_item, order: order, item: item_1)

      expect(merchant.top_3_shipping_cities).to eq(['Houston', 'Denver', 'NYC'])
    end
    it '.top_active_user' do
      user_1 = create(:user)
      address_1 = create(:address, user: user_1, default_add: true, city: 'Denver')
      user_2 = create(:user)
      address_2 = create(:address, user: user_2, default_add: true, city: 'Houston')
      merchant = create(:merchant)
      item_1 = create(:item, user: merchant)

      # user 1 is in 2nd place
      order = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, order: order, item: item_1)
      # user 2 is best to start
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)
      order = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, order: order, item: item_1)

      expect(merchant.top_active_user).to eq(user_2)
      user_2.update(active: false)
      expect(merchant.top_active_user).to eq(user_1)
    end
    it '.biggest_order' do
      user_1 = create(:user)
      address_1 = create(:address, user: user_1, default_add: true, city: 'Denver')
      user_2 = create(:user)
      address_2 = create(:address, user: user_2, default_add: true, city: 'Houston')
      merchant_1, merchant_2 = create_list(:merchant, 2)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)

      # user 1 is in 2nd place
      order_1 = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, quantity: 10, order: order_1, item: item_1)
      create(:fulfilled_order_item, order: order_1, item: item_2)
      # user 2 is best to start
      order_2 = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, quantity: 100, order: order_2, item: item_1)
      create(:fulfilled_order_item, order: order_2, item: item_2)

      expect(merchant_1.biggest_order).to eq(order_2)

      create(:fulfilled_order_item, quantity: 1000, order: order_1, item: item_1)
      expect(merchant_1.biggest_order).to eq(order_1)
    end
    it '.top_buyers(3)' do
      user_1 = create(:user)
      address_1 = create(:address, user: user_1, default_add: true, city: 'Denver')
      user_2 = create(:user)
      address_2 = create(:address, user: user_2, default_add: true, city: 'Houston')
      user_3 = create(:user)
      address_3 = create(:address, user: user_3, default_add: true, city: 'Atlanta')
      merchant_1, merchant_2 = create_list(:merchant, 2)
      item_1 = create(:item, user: merchant_1)
      item_2 = create(:item, user: merchant_2)

      # user 1 is in 2nd place
      order_1 = create(:completed_order, user: user_1, address: address_1)
      create(:fulfilled_order_item, quantity: 100, price: 10, order: order_1, item: item_1)
      create(:fulfilled_order_item, quantity: 100, price: 10, order: order_1, item: item_2)
      # user 2 is 1st place
      order_2 = create(:completed_order, user: user_2, address: address_2)
      create(:fulfilled_order_item, quantity: 1000, price: 10, order: order_2, item: item_1)
      create(:fulfilled_order_item, quantity: 1000, price: 10, order: order_2, item: item_2)
      # user 3 in last place
      order_3 = create(:completed_order, user: user_3, address: address_3)
      create(:fulfilled_order_item, quantity: 10, price: 10, order: order_3, item: item_1)
      create(:fulfilled_order_item, quantity: 10, price: 10, order: order_3, item: item_2)

      expect(merchant_1.top_buyers(3)).to eq([user_2, user_1, user_3])
    end

    it '.default_address' do
      user = create(:user)
      address_1 = create(:address, default_add: false, user: user)
      address_2 = create(:address, default_add: true, user: user)
      address_3 = create(:address, default_add: false, user: user)

      default_address = user.default_address

      expect(default_address.nickname).to eq(address_2.nickname)
    end

    it '.other_addresses' do
      user_1, user_2 = create_list(:user, 2)
      address_1 = create(:address, default_add: false, user: user_1)
      address_2 = create(:address, default_add: true, user: user_1)
      address_3 = create(:address, default_add: false, user: user_1)
      address_4 = create(:address, default_add: true, user: user_2)

      other_addresses = user_1.other_addresses

      expect(other_addresses[0].nickname).to eq(address_1.nickname)
      expect(other_addresses[1].nickname).to eq(address_3.nickname)

      other_addresses = user_2.other_addresses

      expect(other_addresses).to eq([])
    end
  end
end
