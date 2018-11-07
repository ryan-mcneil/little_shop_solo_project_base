require "rails_helper"

describe 'admin visits user show' do
  it 'shows item attributes' do
    @admin = create(:admin)
    @user = create(:user)

    visit login_path
    fill_in :email, with: @admin.email
    fill_in :password, with: @admin.password
    click_button 'Log in'

    visit user_path(@user)

    expect(current_path).to eq("/users/#{@user.slug}")

    expect(page).to have_content(@user.name)

  end

end
