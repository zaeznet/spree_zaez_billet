require 'spec_helper'

describe 'Billet Payments', type: :feature do
  let!(:order1)  { create(:order) }
  let!(:payment) { create(:billet_payment, number: 'P100', order: order1) }

  before { create_admin_in_sign_in }

  context 'show billet info' do
    it 'should show billet information in payments', js: true do
      visit spree.admin_order_payment_path(order1, payment)

      expect(page).to have_text 'Number'
      expect(page).to have_text '1'
      expect(page).to have_text 'Amount'
      expect(page).to have_text '$15.99'
      expect(page).to have_text 'Due Date'
      expect(page).to have_text payment.source.due_date.strftime(I18n.t('date.formats.default'))
      expect(page).to have_css '.label-pending'
      expect(page).to have_text 'PENDING'
    end

    it 'should show generate button when the billet is pending', js: true do
      visit spree.admin_order_payment_path(order1, payment)

      expect(page).to have_link 'Generate Billet'
    end

    it 'should do not show generate button when the billet is paid/void', js: true do
      payment.source.status = 'void'
      payment.source.save

      visit spree.admin_order_payment_path(order1, payment)

      expect(page).not_to have_link 'Generate Billet'
    end
  end

  context 'capture the billet' do
    it 'should capture the payment and update the billet to paid', js: true do
      visit spree.admin_order_payments_path order1
      click_icon :capture
      click_link 'P100'

      expect(page).to have_css  '.label-paid'
      expect(page).to have_text 'PAID'
      expect(page).to have_text 'Paid In'
      expect(page).to have_text Date.today.strftime(I18n.t('date.formats.default'))
    end
  end

  context 'void the billet' do
    it 'should void the payment and update the billet to void', js: true do
      visit spree.admin_order_payments_path order1
      click_icon :void
      click_link 'P100'

      expect(page).to have_css  '.label-void'
      expect(page).to have_text 'VOID'
    end
  end

  context 'billet overdue' do
    let!(:order2)  { create(:order) }
    let!(:payment_overdue) { create(:billet_payment_overdue, number: 'P200', order: order2) }

    it 'should void the old payment and create a new when billet is overdue', js: true do
      allow_any_instance_of(Spree::Billet).to receive(:generate_document).
                                                  and_return(Brcobranca::Boleto::Itau.new(agencia: '1234',
                                                                                          conta_corrente: '12345',
                                                                                          documento_cedente: '12345',
                                                                                          sacado_documento: '12345',
                                                                                          numero_documento: 1))

      visit spree.admin_order_payment_path(order2, payment_overdue)
      click_link 'Generate Billet'

      visit spree.admin_order_payments_path order2

      within_row(1) do
        expect(column_text(6)).to eq 'void'
      end
    end
  end
end