require 'rails_helper'

RSpec.describe 'User Show Page, aka Profile Page' do
  before(:each) do
    @user, @user_2 = create_list(:user, 2)
    @address = create(:address, user: @user, default_add: true, nickname: "Home")
    @address_2 = create(:address, user: @user, default_add: false, nickname: "Work")
  end
  context 'As the user themselves' do
    it 'should show all user data to themselves' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path
      within '.profile-data' do
        expect(page).to have_content(@user.email)
        expect(page).to have_content(@user.name)

        click_link "Edit Profile Data"
        expect(current_path).to eq(profile_edit_path)
      end
      expect(page).to_not have_link("View Personal Orders")
    end
    it 'should show default address and any other addresses' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      within '#default-address' do
        expect(page).to have_content(@address.nickname)
        expect(page).to have_content(@address.street)
        expect(page).to have_content(@address.city)
        expect(page).to have_content(@address.state)
        expect(page).to have_content(@address.zip)
        expect(page).to have_content("DEFAULT")
      end

      within "#other-address-#{@address_2.id}" do
        expect(page).to have_content(@address_2.nickname)
        expect(page).to have_content(@address_2.street)
        expect(page).to have_content(@address_2.city)
        expect(page).to have_content(@address_2.state)
        expect(page).to have_content(@address_2.zip)
      end
    end
    it 'should say they dont have a default address if none are in the system' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_2)

      visit profile_path

      expect(page).to have_content("User has no addresses in the system yet")
    end
    it 'should show the user a link to their personal orders if user has any' do
      order = create(:order, user: @user, address: @address)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      click_link("View Personal Orders")

      expect(current_path).to eq(profile_orders_path)
    end
  end

  context 'As an admin user' do
    it 'should show all user data to an admin' do
      admin = create(:admin)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit user_path(@user)
      within '.profile-data' do
        expect(page).to have_content(@user.email)
        expect(page).to have_content(@user.name)
        expect(page).to have_content(@user.default_address.street)
        expect(page).to have_content(@user.default_address.city)
        expect(page).to have_content(@user.default_address.state)
        expect(page).to have_content(@user.default_address.zip)

        click_link "Edit Profile Data"
        expect(current_path).to eq(edit_user_path(@user))
      end
      expect(page).to_not have_link("View Personal Orders")
    end
    it 'should show a link to orders if user has any' do
      order = create(:order, user: @user, address: @address)
      admin = create(:admin)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

      visit user_path(@user)

      click_link("View Personal Orders")
      expect(current_path).to eq(user_orders_path(@user))
    end
  end

  describe 'Invalid permissions' do
    context 'as a visitor' do
      it 'should block a user profile page from anonymous users' do
        visit user_path(@user)

        expect(page.status_code).to eq(404)
      end
      it 'should block anonymous users trying to get to a profile path' do
        visit profile_path

        expect(page.status_code).to eq(404)
      end
    end

    context 'as another registered user' do
      it 'should block a user profile page from other registered users' do
        user_2 = create(:user, email: 'newuser_2@gmail.com')
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_2)

        visit user_path(@user)

        expect(page.status_code).to eq(404)
      end
      it 'should block access to /dashboard' do
        order = create(:order, user: @user, address: @address)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit dashboard_path

        expect(page.status_code).to eq(404)
      end
      it 'should block access to /dashboard' do
        order = create(:order, user: @user, address: @address)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit dashboard_path

        expect(page.status_code).to eq(404)
      end
    end

    context 'as a merchant' do
      it 'should block a user profile page from anonymous users' do
        merchant = create(:merchant)
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merchant)

        visit user_path(@user)

        expect(page.status_code).to eq(404)
      end
    end
  end
end
