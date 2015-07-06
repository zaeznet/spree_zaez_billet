require 'spec_helper'

describe 'Billet Settings', type: :feature do

  before { create_admin_in_sign_in }

  context 'visit billet settings' do
    it 'should be a link to billet settings' do
      within('.sidebar') { page.find_link('Billet Settings')['/admin/billet_settings/edit'] }
    end
  end

  context 'show billet settings' do
    it 'should show common billet settings', js: true do
      Spree::BilletConfig.bank = ''
      visit spree.edit_admin_billet_settings_path

      expect(page).to have_selector '#bank'
      expect(page).to have_selector '#corporate_name'
      expect(page).to have_selector '#document'
      expect(page).to have_selector '#address'
      expect(page).to have_selector '#agency'
      expect(page).to have_selector '#account'
      expect(page).to have_selector '#registered'
      expect(page).to have_selector '#due_date'
      expect(page).to have_selector '[name=acceptance]'
      expect(page).to have_selector '#instruction_1'
      expect(page).to have_selector '#instruction_2'
      expect(page).to have_selector '#instruction_3'
      expect(page).to have_selector '#instruction_4'
      expect(page).to have_selector '#instruction_5'
      expect(page).to have_selector '#instruction_6'
    end

    it 'should clear the shipping number', js: true do
      Spree::BilletConfig.shipping_number = 19
      visit spree.edit_admin_billet_settings_path

      click_link 'Clear Number'

      expect(find_field('shipping_number', disabled: true).value).to eq '1'
    end

    context 'choosing the bank' do
      before { visit spree.edit_admin_billet_settings_path }

      it 'do not show specific fields when any bank is selected', js: true do
        expect(page).not_to have_selector '#wallet'
        expect(page).not_to have_selector '#variation_wallet'
        expect(page).not_to have_selector '#agreement'
        expect(page).not_to have_selector '#account_digit'
        expect(page).not_to have_selector '#company_code'
        expect(page).not_to have_selector '#office_code'
        expect(page).not_to have_selector '#app_version'
        expect(page).not_to have_selector '#byte_idt'
      end

      it 'should show fields of Banco do Brasil', js: true do
        select2 'Banco do Brasil', from: 'Bank'

        expect(page).to have_selector '#agreement'
        expect(page).to have_selector '#wallet'
        expect(page).to have_selector '#variation_wallet'
      end

      it 'should show fields of Caixa', js: true do
        select2 'Caixa Econômica Federal', from: 'Bank'

        expect(page).to have_selector '#agreement'
        expect(page).to have_selector '#account_digit'
        expect(page).to have_selector '#app_version'
      end

      it 'should show fields of Bradesco', js: true do
        select2 'Bradesco', from: 'Bank'

        expect(page).to have_selector '#wallet'
        expect(page).to have_selector '#account_digit'
        expect(page).to have_selector '#company_code'
      end

      it 'should show fields of Itaú', js: true do
        select2 'Itaú', from: 'Bank'

        expect(page).to have_selector '#wallet'
        expect(page).to have_selector '#account_digit'
        expect(page).to have_selector '#agreement'
      end

      it 'should show fields of HSBC', js: true do
        select2 'HSBC', from: 'Bank'

        expect(page).to have_selector '#wallet'
      end

      it 'should show fields of Santander', js: true do
        select2 'Santander Banespa', from: 'Bank'

        expect(page).to have_selector '#wallet'
        expect(page).to have_selector '#agreement'
      end

      it 'should show fields of Sicredi', js: true do
        select2 'Sicredi', from: 'Bank'

        expect(page).to have_selector '#wallet'
        expect(page).to have_selector '#byte_idt'
        expect(page).to have_selector '#office_code'
      end
    end
  end

  context 'edit billet settings' do
    before { visit spree.edit_admin_billet_settings_path }

    it 'can edit bank', js: true do
      select2 'Bradesco', from: 'Bank'
      click_button 'Update'

      expect(Spree::BilletConfig.bank).to eq 'bradesco'
      expect(find_field('bank').value).to eq 'bradesco'

      # set default
      Spree::BilletConfig.bank = ''
    end

    {corporate_name: 'some name LTDA',
     document: '123',
     address: 'full address',
     agency: '1234',
     account: '12345',
     instruction_1: '1st instruction',
     instruction_2: '2nd instruction',
     instruction_3: '3rd instruction',
     instruction_4: '4th instruction',
     instruction_5: '5th instruction',
     instruction_6: '6th instruction'}.each do |key, value|
      it "can edit #{key}", js: true do
        fill_in key.to_s, with: value
        click_button 'Update'

        verify_input_value key.to_s, Spree::BilletConfig, value, ''
      end
    end

    [{name: 'agreement', value: '123456', bank: 'Banco do Brasil'},
     {name: 'wallet', value: '123', bank: 'Banco do Brasil'},
     {name: 'variation_wallet', value: '1', bank: 'Banco do Brasil'},
     {name: 'account_digit', value: '1', bank: 'Bradesco'},
     {name: 'app_version', value: '123456', bank: 'Caixa Econômica Federal'},
     {name: 'company_code', value: '1234', bank: 'Bradesco'},
     {name: 'office_code', value: '12', bank: 'Sicredi'},
     {name: 'byte_idt', value: '12', bank: 'Sicredi'}].each do |item|
      it "can edit #{item[:name]}", js: true do
        select2 item[:bank], from: 'Bank'
        fill_in item[:name], with: item[:value]
        click_button 'Update'

        verify_input_value item[:name], Spree::BilletConfig, item[:value], ''
      end
    end

    it 'can edit due date' do
      fill_in 'due_date', with: 3
      click_button 'Update'

      expect(Spree::BilletConfig.due_date).to eq 3
      expect(find_field('due_date').value).to eq '3'

      # set default
      Spree::BilletConfig.due_date = 5
    end

    it 'can edit acceptance', js: true do
      find(:css, '#acceptance_S').set true
      click_button 'Update'

      expect(Spree::BilletConfig.acceptance).to eq 'S'
      expect(find_field('acceptance_S')).to be_checked

      # set default
      Spree::BilletConfig.acceptance = 'N'
    end

    it 'can edit document customer attribute', js: true do
      select2 'Authentication Token', from: 'Document Customer Attribute'
      click_button 'Update'

      expect(Spree::BilletConfig.doc_customer_attr).to eq 'authentication_token'
      expect(find_field('doc_customer_attr').value).to eq 'authentication_token'

      # set default
      Spree::BilletConfig.doc_customer_attr = ''
    end

    it 'can edit if the billet is registered', js: true do
      find(:css, '#registered').set false
      click_button 'Update'

      expect(Spree::BilletConfig.registered).to eq false
      expect(find_field('registered')).not_to be_checked

      # set default
      Spree::BilletConfig.registered = true
    end
  end
end