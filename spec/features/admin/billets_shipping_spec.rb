require 'spec_helper'

describe 'Billets Shipping', type: :feature do

  before { create_admin_in_sign_in }

  let!(:payment) { FactoryGirl.build(:payment, id: 1) }
  let!(:billet)  { FactoryGirl.build(:billet, status: 'waiting_registry', payment: payment) }

  it 'should show a message when there are not any billets to registry', js: true do

    visit spree.admin_billets_shipping_path

    expect(page).to have_text 'No Billets found'
    expect(page).not_to have_button 'Register Billets'
  end

  context 'with unregistered billets' do

    before do
      billet
      allow(Spree::Billet).to receive(:unregistered).and_return([billet])
      visit spree.admin_billets_shipping_path
    end

    it 'should show the information about unregistered billets', js: true do
      expect(page).to have_button 'Register Billets'

      within_row(1) do
        expect(column_text(1)).to eq '1'
        expect(column_text(2)).to eq billet.customer_name
        expect(column_text(3)).to eq '$10.00'
        expect(column_text(4)).to eq Date.today.strftime(I18n.t('date.formats.default'))
        expect(column_text(5)).to eq billet.due_date.strftime(I18n.t('date.formats.default'))
      end
    end

    it 'should show an error message when the bank is not selected', js: true do
      Spree::BilletConfig.bank = ''

      click_button 'Register Billets'
      expect(page).to have_text 'The Bank selected in settings is not implemented!'
    end

    it 'should show an error message when any billets are valid', js: true do
      # set the bank in billets configuration
      Spree::BilletConfig.bank = 'caixa'

      click_button 'Register Billets'
      expect(page).to have_text 'The billets are invalid!'

      # set default
      Spree::BilletConfig.bank = ''
    end

    it 'should generate the billet', js: true do
      # set the bank in billets configuration
      Spree::BilletConfig.bank = 'bradesco'
      Spree::BilletConfig.corporate_name = 'some name'
      Spree::BilletConfig.agency = '1234'
      Spree::BilletConfig.account = '123'
      Spree::BilletConfig.wallet = '12'
      Spree::BilletConfig.company_code = '12345'
      Spree::BilletConfig.account_digit = '1'
      # using authentication token to storage document customer
      Spree::BilletConfig.doc_customer_attr = 'authentication_token'
      billet.user.authentication_token = '123456789010'
      billet.order.bill_address.zipcode = '12345678'
      # stub the save method
      allow(billet).to receive(:save).and_return(nil)

      click_button 'Register Billets'

      expect(page).not_to have_css '.alert .alert-danger'

      # set default
      Spree::BilletConfig.bank = ''
      Spree::BilletConfig.corporate_name = ''
      Spree::BilletConfig.agency = ''
      Spree::BilletConfig.account = ''
      Spree::BilletConfig.wallet = ''
      Spree::BilletConfig.company_code = ''
      Spree::BilletConfig.account_digit = ''
      Spree::BilletConfig.doc_customer_attr = ''
    end
  end
end