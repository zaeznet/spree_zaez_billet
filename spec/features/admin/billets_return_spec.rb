require 'spec_helper'

describe 'Billets Return', type: :feature do
  let!(:order)   { create(:order) }
  let!(:payment) { create(:billet_payment, number: 'P100', order: order) }

  let(:file_path) { Rails.root + '../../spec/fixtures/files/cnab240.ret' }
  let(:file_path_without_return) { Rails.root + '../../spec/fixtures/files/cnab400.ret' }

  before { create_admin_in_sign_in }

  it 'should read return and show the paid payments', js: true do
    payment
    visit spree.admin_billets_return_path

    find(:css, '#file_type_cnab240').set true
    attach_file('file', file_path)
    click_button 'Continue'

    within_row(1) do
      expect(column_text(1)).to eq '00000001'
      expect(column_text(2)).to eq '$322.20'
      expect(column_text(3)).to eq '2002-01-20'
      expect(column_text(4)).to eq order.number
    end
  end

  it 'should show an message when any billets was paid', js: true do
    payment
    visit spree.admin_billets_return_path

    find(:css, '#file_type_cnab400').set true
    attach_file('file', file_path_without_return)

    click_button 'Continue'

    expect(page).to have_text 'There is not return in attached file.'
  end
end