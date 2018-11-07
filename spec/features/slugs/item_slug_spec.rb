require "rails_helper"

describe 'user visits item show' do
  it 'shows item attributes' do
    @merchant = create(:merchant)
    item_1, item_2 = create_list(:item, 2, user: @merchant)

    visit item_path(item_1)

    expect(current_path).to eq("/items/#{item_1.slug}")

    expect(page).to have_content(item_1.name)

  end

end
