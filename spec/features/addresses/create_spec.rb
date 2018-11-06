require 'rails_helper'

RSpec.describe 'Create Address' do
  context 'as a registered user' do
    before :each do
      @user = create(:user)
    end

    it 'allows me to add a first address, and it is set to default' do
      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button 'Log in'

      visit profile_path

      click_on "Add New Address"

      expect(current_path).to eq(new_profile_address_path)

      fill_in :address_street, with: 'New Street'
      fill_in :address_city, with: 'New City'
      fill_in :address_state, with: 'New State'
      fill_in :address_zip, with: 'New Zip'
      fill_in :address_nickname, with: 'New Nickname'
      click_button 'Create Address'

      expect(current_path).to eq(profile_path)
      within '#default-address' do
        expect(page).to have_content('New Street')
        expect(page).to have_content('New City')
        expect(page).to have_content('New State')
        expect(page).to have_content('New Zip')
        expect(page).to have_content('New Nickname')
        expect(page).to have_content("DEFAULT")
      end

    end

    it 'allows me to add more, non defaulted addresses' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)
      address = create(:address, user: @user, default_add: true)

      visit profile_path

      click_on "Add New Address"

      expect(current_path).to eq(new_profile_address_path)

      fill_in :address_street, with: 'New Street'
      fill_in :address_city, with: 'New City'
      fill_in :address_state, with: 'New State'
      fill_in :address_zip, with: 'New Zip'
      fill_in :address_nickname, with: 'New Nickname'
      click_button 'Create Address'

      expect(current_path).to eq(profile_path)

      within '#default-address' do
        expect(page).to have_content(address.nickname)
        expect(page).to have_content("DEFAULT")
      end

      within "#other-address-#{@user.addresses.last.id}" do
        expect(page).to have_content('New Street')
        expect(page).to have_content('New City')
        expect(page).to have_content('New State')
        expect(page).to have_content('New Zip')
        expect(page).to have_content('New Nickname')
      end
    end

    it 'should not create an address if any fields are blank' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      click_on "Add New Address"
      click_button 'Create Address'

      expect(page).to have_content("Street can't be blank")
      expect(page).to have_content("City can't be blank")
      expect(page).to have_content("State can't be blank")
      expect(page).to have_content("Zip can't be blank")
      expect(page).to have_content("Nickname can't be blank")
    end
  end

  context 'as an admin' do

    before :each do
      @admin = create(:admin)
      @user = create(:user)
      @user_address = create(:address, user: @user, default_add: true)
    end

    it 'allows me to add more, non defaulted addresses to user' do
      visit login_path
      fill_in :email, with: @admin.email
      fill_in :password, with: @admin.password
      click_button 'Log in'

      visit user_path(@user)

      click_on "Add New Address"

      fill_in :address_street, with: 'New Street'
      fill_in :address_city, with: 'New City'
      fill_in :address_state, with: 'New State'
      fill_in :address_zip, with: 'New Zip'
      fill_in :address_nickname, with: 'New Nickname'
      click_button 'Create Address'

      expect(current_path).to eq(user_path(@user))

      within '#default-address' do
        expect(page).to have_content(@user_address.nickname)
        expect(page).to have_content("DEFAULT")
      end

      within "#other-address-#{@user.addresses.last.id}" do
        expect(page).to have_content('New Street')
        expect(page).to have_content('New City')
        expect(page).to have_content('New State')
        expect(page).to have_content('New Zip')
        expect(page).to have_content('New Nickname')
      end
    end

    it 'should not create an address if any fields are blank' do
      visit login_path
      fill_in :email, with: @admin.email
      fill_in :password, with: @admin.password
      click_button 'Log in'

      visit user_path(@user)

      click_on "Add New Address"
      click_button 'Create Address'

      expect(page).to have_content("Street can't be blank")
      expect(page).to have_content("City can't be blank")
      expect(page).to have_content("State can't be blank")
      expect(page).to have_content("Zip can't be blank")
      expect(page).to have_content("Nickname can't be blank")
    end


  end
end
