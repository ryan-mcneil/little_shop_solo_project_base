require 'rails_helper'

RSpec.describe 'Update Address' do
  context 'as a registered user' do
    before :each do
      @user = create(:user)

      visit login_path
      fill_in :email, with: @user.email
      fill_in :password, with: @user.password
      click_button 'Log in'
    end

    it 'allows an address to be updated' do
      address = create(:address, user: @user, default_add: true)

      visit profile_path

      within '#default-address' do
        click_on "Edit Address"
      end

      expect(current_path).to eq(edit_address_path(address))

      fill_in :address_street, with: 'New Street'
      fill_in :address_city, with: 'New City'
      fill_in :address_state, with: 'New State'
      fill_in :address_zip, with: 'New Zip'
      fill_in :address_nickname, with: 'New Nickname'
      click_button 'Update Address'

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

    it 'allows a non default address to be updated' do
      address = create(:address, user: @user, default_add: true)
      address_2 = create(:address, user: @user, default_add: false, nickname: "work")

      visit profile_path

      within "#other-address-#{address_2.id}" do
        click_on "Edit Address"
      end

      expect(current_path).to eq(edit_address_path(address_2))

      fill_in :address_street, with: 'New Street'
      fill_in :address_city, with: 'New City'
      fill_in :address_state, with: 'New State'
      fill_in :address_zip, with: 'New Zip'
      fill_in :address_nickname, with: 'New Nickname'
      click_button 'Update Address'

      expect(current_path).to eq(profile_path)
      within "#other-address-#{address_2.id}" do
        expect(page).to have_content('New Street')
        expect(page).to have_content('New City')
        expect(page).to have_content('New State')
        expect(page).to have_content('New Zip')
        expect(page).to have_content('New Nickname')
      end
    end

    it 'should be able to disable a default address' do
      address = create(:address, user: @user, default_add: true)

      visit profile_path

      within '#default-address' do
        expect(page).to_not have_button("Enable")
        click_button "Disable"
      end
      expect(page).to have_content("'#{address.nickname}' address is now disabled")

      within '#default-address' do
        expect(page).to have_button("Enable")
      end


    end

    it 'should be able to enable a disabled default address' do
      address = create(:address, user: @user, default_add: true)

      visit profile_path

      within '#default-address' do
        click_button "Disable"
      end

      within '#default-address' do
        click_button "Enable"
      end
      expect(page).to have_content("'#{address.nickname}' address is now enabled")

      within '#default-address' do
        expect(page).to have_button("Disable")
      end

    end

    it 'should be able to disable and then enable other addresses' do
      address = create(:address, user: @user, default_add: true)
      address_2 = create(:address, user: @user, default_add: false, nickname: "work")

      visit profile_path

      within "#other-address-#{address_2.id}" do
        click_button "Disable"
      end
      expect(page).to have_content("'#{address_2.nickname}' address is now disabled")

      within "#other-address-#{address_2.id}" do
        click_button "Enable"
      end
      expect(page).to have_content("'#{address_2.nickname}' address is now enabled")

      within "#other-address-#{address_2.id}" do
        expect(page).to have_button("Disable")
      end

    end

    xit 'should replace default if default is disabled' do
      address = create(:address, user: @user, default_add: true)
      address_2 = create(:address, user: @user, default_add: false, nickname: "work")

      visit profile_path

      within '#default-address' do
        click_button "Disable"
      end
      expect(page).to have_content("'#{address.nickname}' address is now disabled")

      within '#default-address' do
        expect(page).to have_content("(#{address_2.nickname})")
        expect(page).to have_button("Disable")

      end

      within "#other-address-#{address.id}" do
        expect(page).to have_content("(#{address.nickname})")
        expect(page).to have_button("Enable")
      end
    end

    it 'should set a new default address' do
      address = create(:address, user: @user, default_add: true)
      address_2 = create(:address, user: @user, default_add: false, nickname: "work")

      visit profile_path

      within '#default-address' do
        expect(page).to have_content("DEFAULT")
      end

      within "#other-address-#{address_2.id}" do
        click_button "Make Default"
      end
      expect(page).to have_content("'#{address_2.nickname}' address is now your default")

      within '#default-address' do
        expect(page).to have_content("(#{address_2.nickname})")
      end
    end
  end

  context 'as an admin' do

    before :each do
      @admin = create(:admin)
      @user = create(:user)
      @user_address = create(:address, user: @user, default_add: true)

      visit login_path
      fill_in :email, with: @admin.email
      fill_in :password, with: @admin.password
      click_button 'Log in'
    end

    it 'should be able to update a users address' do

      visit user_path(@user)

      within '#default-address' do
        click_on "Edit Address"
      end

      expect(current_path).to eq(edit_address_path(@user_address))

      fill_in :address_street, with: 'New Street'
      fill_in :address_city, with: 'New City'
      fill_in :address_state, with: 'New State'
      fill_in :address_zip, with: 'New Zip'
      fill_in :address_nickname, with: 'New Nickname'
      click_button 'Update Address'

      expect(current_path).to eq(user_path(@user))
      within '#default-address' do
        expect(page).to have_content('New Street')
        expect(page).to have_content('New City')
        expect(page).to have_content('New State')
        expect(page).to have_content('New Zip')
        expect(page).to have_content('New Nickname')
        expect(page).to have_content("DEFAULT")
      end
    end

    it 'should be able to disable and then enable address as admin' do

      visit user_path(@user)

      within '#default-address' do
        click_button "Disable"
      end
      expect(current_path).to eq(user_path(@user))
      expect(page).to have_content("'#{@user_address.nickname}' address is now disabled")

      within '#default-address' do
        click_button "Enable"
      end
      expect(page).to have_content("'#{@user_address.nickname}' address is now enabled")

      within '#default-address' do
        expect(page).to have_button("Disable")
      end

    end

    it 'should set a new default address for a user' do
      @user_address_2 = create(:address, user: @user, default_add: false, nickname: "work")

      visit user_path(@user)

      within '#default-address' do
        expect(page).to have_content("DEFAULT")
      end

      within "#other-address-#{@user_address_2.id}" do
        click_button "Make Default"
      end
      expect(page).to have_content("'#{@user_address_2.nickname}' address is now your default")

      within '#default-address' do
        expect(page).to have_content("(#{@user_address_2.nickname})")
      end
    end

  end
end
