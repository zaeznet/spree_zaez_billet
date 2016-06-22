require 'spec_helper'

describe Spree::Billet do

  let(:payment) { FactoryGirl.build(:payment) }
  let(:billet)  { FactoryGirl.build(:billet, status: 'pending', payment: payment) }

  it 'should return true when billet is pending' do
    expect(billet.pending?).to be true
  end

  it 'should return true when billet is paid' do
    billet.status = 'paid'
    expect(billet.paid?).to be true
  end

  it 'should return true when billet is waiting registry' do
    billet.status = 'waiting_registry'
    expect(billet.waiting_registry?).to be true
  end

  it 'should return if the document can be generated' do
    billet.status = 'waiting_registry'
    expect(billet.can_generate_document?).to be true
    billet.status = 'pending'
    expect(billet.can_generate_document?).to be true

    # when is void or paid
    billet.status = 'void'
    expect(billet.can_generate_document?).to be false
    billet.status = 'paid'
    expect(billet.can_generate_document?).to be false
  end

  it 'should change the status to pending' do
    billet.status = 'void'
    # stub the save method
    allow(billet).to receive(:save).and_return(nil)
    billet.to_pending!
    expect(billet.status).to eq 'pending'
  end

  it 'should return the customer name' do
    bill_address = billet.order.bill_address
    bill_address.firstname = 'name'
    bill_address.lastname = 'lastname'

    expect(billet.customer_name).to eq 'name lastname'
  end

  it 'should return the due date' do
    Spree::BilletConfig.due_date = 1

    expect(billet.due_date).to eq(Date.today + 1.days)

    # set default
    Spree::BilletConfig.due_date = 5
  end

  context 'actions options' do
    it 'should return when can capture the billet' do
      payment.state = 'checkout'
      expect(billet.can_capture?(payment)).to be true

      payment.state = 'pending'
      expect(billet.can_capture?(payment)).to be true

      payment.state = 'void'
      expect(billet.can_capture?(payment)).to be false
    end

    it 'should return when can void the billet' do
      payment.state = 'checkout'
      expect(billet.can_void?(payment)).to be true

      payment.state = 'pending'
      expect(billet.can_void?(payment)).to be true

      payment.state = 'processing'
      expect(billet.can_void?(payment)).to be true

      payment.state = 'void'
      expect(billet.can_void?(payment)).to be false

      payment.state = 'failure'
      expect(billet.can_void?(payment)).to be false

      payment.state = 'invalid'
      expect(billet.can_void?(payment)).to be false
    end

    it 'should return the actions to payment according to state' do
      payment.state = 'checkout'
      expect(billet.actions).to eq %w(capture void)

      payment.state = 'processing'
      expect(billet.actions).to eq %w(void)

      payment.state = 'void'
      expect(billet.actions).to eq []
    end
  end

  describe 'displaying amount' do
    let(:order_currency) { FactoryGirl.build(:order, currency: 'USD') }
    let(:billet_with_order) { FactoryGirl.build(:billet, amount: 12.0, order: order_currency) }

    it 'should return the currency according to order' do
      expect(billet_with_order.currency).to eq 'USD'
    end

    it 'should return amount converted to money according to currency' do
      amount = billet_with_order.display_amount
      expect(amount).to eq(Spree::Money.new(billet_with_order.amount))
      expect(amount.to_html).to eq '$12.00'

      # modifying the currency
      order_currency.currency = 'BRL'
      new_amount = billet_with_order.display_amount
      expect(new_amount.to_html).to eq 'R$12.00'
    end
  end

  # tests from spree/core/spec/models/spree/payment_spec
  describe '#amount=' do
    before do
      subject.amount = amount
    end

    context 'when the amount is a string' do
      context 'amount is a decimal' do
        let(:amount) { '2.99' }

        it '#amount' do
          expect(subject.amount).to eq BigDecimal('2.99')
        end
      end

      context 'amount is an integer' do
        let(:amount) { '2' }

        it '#amount' do
          expect(subject.amount).to eq BigDecimal('2.0')
        end
      end

      context 'amount contains a dollar sign' do
        let(:amount) { '$2.99' }

        it '#amount' do
          expect(subject.amount).to eq BigDecimal('2.99')
        end
      end

      context 'amount contains a comma' do
        let(:amount) { '$2,999.99' }

        it '#amount' do
          expect(subject.amount).to eq BigDecimal('2999.99')
        end
      end

      context 'amount contains a negative sign' do
        let(:amount) { '-2.99' }

        it '#amount' do
          expect(subject.amount).to eq BigDecimal('-2.99')
        end
      end

      context 'amount is invalid' do
        let(:amount) { 'invalid' }

        it '#amount' do
          expect(subject.amount).to eq BigDecimal('0')
        end
      end

      context 'amount is an empty string' do
        let(:amount) { '' }

        it '#amount' do
          expect(subject.amount).to be_nil
        end
      end
    end

    context 'when the amount is a number' do
      let(:amount) { 1.55 }

      it '#amount' do
        expect(subject.amount).to eq BigDecimal('1.55')
      end
    end
  end

  context 'generating billet document' do

    let(:order) { FactoryGirl.build(:order) }

    before(:all) do
      Spree::BilletConfig.corporate_name = 'some name'
      Spree::BilletConfig.document = '12345'
      Spree::BilletConfig.address = 'full address'
      Spree::BilletConfig.agency = '1234'
      Spree::BilletConfig.account = '123'
      Spree::BilletConfig.agreement = '123456'
      Spree::BilletConfig.wallet = '212'
      Spree::BilletConfig.variation_wallet = '12'
      Spree::BilletConfig.instruction_1 = '1st instruction'
      Spree::BilletConfig.instruction_2 = '2nd instruction'
      Spree::BilletConfig.instruction_3 = '3rd instruction'
      Spree::BilletConfig.instruction_4 = '4th instruction'
      Spree::BilletConfig.instruction_5 = '5th instruction'
      Spree::BilletConfig.instruction_6 = '6th instruction'
    end

    it 'should generate the document' do
      order.payments << payment
      Spree::BilletConfig.bank = 'banco_brasil'

      document = billet.generate_document

      expect(document.cedente).to eq 'some name'
      expect(document.documento_cedente).to eq '12345'
      expect(document.cedente_endereco).to eq 'full address'
      expect(document.sacado).to eq "#{order.bill_address.firstname} #{order.bill_address.lastname}"
      expect(document.sacado_documento).to eq billet.user.attributes[Spree::BilletConfig.doc_customer_attr]
      expect(document.sacado_endereco).to eq order.bill_address.full_address
      expect(document.numero_documento).to eq '00001'   # 5 posicoes quando o convenio tem 6 digitos para BB
      expect(document.data_vencimento).to eq(Date.today + Spree::BilletConfig.due_date.days)
      expect(document.data_documento).to eq Date.today
      expect(document.valor).to eq 10.0
      expect(document.aceite).to eq 'N'
      expect(document.agencia).to eq '1234'
      expect(document.conta_corrente).to eq '00000123' # 8 digitos
      expect(document.convenio).to eq '123456'
      expect(document.carteira).to eq '212'
      expect(document.variacao).to eq '12'
      expect(document.instrucao1).to eq '1st instruction'
      expect(document.instrucao2).to eq '2nd instruction'
      expect(document.instrucao3).to eq '3rd instruction'
      expect(document.instrucao4).to eq '4th instruction'
      expect(document.instrucao5).to eq '5th instruction'
      expect(document.instrucao6).to eq '6th instruction'
    end

    context 'different banks' do

      {'banco_brasil' => Brcobranca::Boleto::BancoBrasil,
       'bradesco'     => Brcobranca::Boleto::Bradesco,
       'caixa'        => Brcobranca::Boleto::Caixa,
       'santander'    => Brcobranca::Boleto::Santander,
       'itau'         => Brcobranca::Boleto::Itau,
       'sicredi'      => Brcobranca::Boleto::Sicredi}.each do |key, value|

        it "should return object #{value}" do
          order.payments << payment
          Spree::BilletConfig.bank = key
          document = billet.generate_document

          expect(document.is_a?(value)).to be true
        end
      end

      it 'raise an error when ay bank is set' do
        order.payments << payment
        Spree::BilletConfig.bank = ''
        expect { billet.generate_document }.to raise_error('It is necessary set the billet config')
      end
    end
  end

  context 'generating shipping file' do
    before(:all) do
      Spree::BilletConfig.corporate_name = 'some name'
      Spree::BilletConfig.document = '12345678910'
      Spree::BilletConfig.address = 'full address'
      Spree::BilletConfig.agency = '1234'
      Spree::BilletConfig.account = '123'
      Spree::BilletConfig.agreement = '123456'
      Spree::BilletConfig.wallet = '212'
      Spree::BilletConfig.variation_wallet = '12'
      Spree::BilletConfig.account_digit = '1'
      # using authentication token to storage document customer
      Spree::BilletConfig.doc_customer_attr = 'authentication_token'
    end

    def prepare_object
      Spree::BilletConfig.bank = 'itau'
      billet.status = 'waiting_registry'
      billet.user.authentication_token = '12345678910'
      billet.order.bill_address.zipcode = '12345678'

      # stub the scope and the save method
      allow(Spree::Billet).to receive(:unregistered).and_return([billet])
      allow(billet).to receive(:save).and_return(nil)
    end

    it 'shipping number should iterate when shipping is generated' do
      prepare_object
      number = Spree::BilletConfig.shipping_number
      _shipping = Spree::Billet.generate_shipping

      expect(Spree::BilletConfig.shipping_number).to eq(number + 1)
    end

    it 'should return shipping' do
      prepare_object
      shipping = Spree::Billet.generate_shipping

      expect(shipping.class).to eq String
    end

    it 'the status of billets should change to pending' do
      prepare_object
      _shipping = Spree::Billet.generate_shipping

      expect(billet.status).to eq 'pending'
    end

    context 'raise errors' do
      it 'should return an error when any bank is selected' do
        prepare_object
        Spree::BilletConfig.bank = ''
        shipping = Spree::Billet.generate_shipping

        expect(shipping[:reason]).to eq :billet_bank_not_implemented
      end

      it 'should return an error when any billet is unregistered' do
        shipping = Spree::Billet.generate_shipping

        expect(shipping[:reason]).to eq :there_are_not_any_billets_to_registry
      end

      it 'should return an error when the billets are invalid' do
        prepare_object
        billet.order.bill_address.zipcode = '123'
        shipping = Spree::Billet.generate_shipping

        expect(shipping[:reason]).to eq :invalid_billets
      end
    end
  end

  after(:all) do
    Spree::BilletConfig.bank = ''
    Spree::BilletConfig.corporate_name = ''
    Spree::BilletConfig.document = ''
    Spree::BilletConfig.address = ''
    Spree::BilletConfig.agency = ''
    Spree::BilletConfig.account = ''
    Spree::BilletConfig.agreement = ''
    Spree::BilletConfig.wallet = ''
    Spree::BilletConfig.variation_wallet = ''
    Spree::BilletConfig.account_digit = ''
    Spree::BilletConfig.doc_customer_attr = ''
    Spree::BilletConfig.instruction_1 = ''
    Spree::BilletConfig.instruction_2 = ''
    Spree::BilletConfig.instruction_3 = ''
    Spree::BilletConfig.instruction_4 = ''
    Spree::BilletConfig.instruction_5 = ''
    Spree::BilletConfig.instruction_6 = ''
  end
end