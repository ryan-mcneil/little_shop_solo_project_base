require 'rails_helper'

RSpec.describe Address, type: :model do
  describe 'Relationships' do
    it { should belong_to(:user) }
  end

  describe 'Validations' do

    it { should validate_presence_of :street }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end
end
