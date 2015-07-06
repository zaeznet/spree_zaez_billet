require 'spec_helper'

describe 'Checkout with Billet Payment Method', type: :feature do

  include_context 'checkout setup'

  context 'auto capture payment equals to false' do
    before do
      payment_method.auto_capture = false
      payment_method.save
    end

    it 'should create a order with billet', js: true do
      add_mug_to_cart
      click_button 'Checkout'

      fill_in 'order_email', :with => 'test@example.com'
      click_on 'Continue'
      fill_in_address

      # confirm address
      click_button 'Save and Continue'
      # confirm shipping method
      click_button 'Save and Continue'
      # confirm payment method (billet)
      click_button 'Save and Continue'
      expect(page).to have_content 'Payment by Billet'
      expect(page).to have_link 'Generate Billet'

      expect(Spree::Billet.count).to eq 1

      if Spree::BilletConfig.registered
        expect(Spree::Billet.first.waiting_registry?).to be true
      else
        expect(Spree::Billet.first.pending?).to be true
      end
    end
  end

  context 'auto capture payment equals to true' do
    before do
      payment_method.auto_capture = true
      payment_method.save
    end

    it 'should create a order with billet', js: true do
      add_mug_to_cart
      click_button 'Checkout'

      fill_in 'order_email', :with => 'test@example.com'
      click_on 'Continue'
      fill_in_address

      # confirm address
      click_button 'Save and Continue'
      # confirm shipping method
      click_button 'Save and Continue'
      # confirm payment method (billet)
      click_button 'Save and Continue'
      expect(page).to have_content 'Payment by Billet'

      expect(Spree::Billet.count).to eq 1
      expect(Spree::Billet.first.paid?).to be true
    end
  end

  def fill_in_address
    address = 'order_bill_address_attributes'
    fill_in "#{address}_firstname", with: 'Ryan'
    fill_in "#{address}_lastname", with: 'Bigg'
    fill_in "#{address}_address1", with: '143 Swan Street'
    fill_in "#{address}_city", with: 'Richmond'
    select 'United States of America', from: "#{address}_country_id"
    select 'Alabama', from: "#{address}_state_id"
    fill_in "#{address}_zipcode", with: '12345'
    fill_in "#{address}_phone", with: '(555) 555-5555'
  end

  def add_mug_to_cart
    visit spree.root_path
    click_link mug.name
    click_button 'add-to-cart-button'
  end
end