require 'spec_helper'

describe Spree::BilletConfiguration do

  let(:config) { Spree::BilletConfiguration.new }

  [:bank, :corporate_name, :document, :address, :agency, :account, :agreement, :wallet,
   :variation_wallet, :due_date, :acceptance, :instruction_1, :instruction_2, :instruction_3,
   :instruction_4, :instruction_5, :instruction_6, :doc_customer_attr].each do |preference|
    it "should has the #{preference} preference" do
      expect(config.has_preference?(preference)).to be true
    end
  end
end