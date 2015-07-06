require 'spec_helper'

describe Spree::Address do

  context 'full address' do
    let(:address) { FactoryGirl.build(:address, address1: 'street', address2: 'district', city: 'city', zipcode: '12345') }

    it 'should show the full address' do
      state_abbr = address.state.abbr
      expect(address.full_address).to eq "street, district - 12345 - city/#{state_abbr}"
    end
  end
end