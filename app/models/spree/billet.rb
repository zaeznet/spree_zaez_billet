module Spree
  class Billet < ActiveRecord::Base

    has_one :payment, as: :source
    belongs_to :order
    belongs_to :user
    belongs_to :payment_method

    scope :unregistered, -> { where(status: 'waiting_registry') }

    # Displays what actions can be done according to payment method
    #
    # @author Isabella Santos
    #
    # @return [Array]
    #
    def actions
      act = []
      act << 'capture' if can_capture? payment
      act << 'void' if can_void? payment
      act
    end

    # Save the amount of the billet
    # if amount is a string, convert to a BigDecimal
    #
    # copy of Spree::Payment.amount
    #
    def amount=(amount)
      self[:amount] =
          case amount
            when String
              separator = I18n.t('number.currency.format.separator')
              number    = amount.delete("^0-9-#{separator}\.").tr(separator, '.')
              number.to_d if number.present?
          end || amount
    end

    # Determines whether can capture the payment
    # (only can capture when the state is checkout or pending)
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    # Determines whether can void the payment
    # (only can void when the state is different of void, failure or invalid)
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def can_void?(payment)
      !%w(void failure invalid).include?(payment.state)
    end

    # Defines the currency of the billet
    # based in te currency of the order
    #
    # copy of Spree::Payment.currency
    #
    def currency
      order.currency
    end

    # Calculates the due date
    # according to created at
    #
    # @author Isabella Santos
    #
    # @return [Date]
    #
    def due_date
      created_at + Spree::BilletConfig.due_date.days
    end

    # Generate the object from gem brcobranca
    #
    # @author Isabella Santos
    #
    # @return [Brcobranca::Boleto::Base]
    #
    def generate_document
      config = Spree::BilletConfig
      doc_user = user.attributes[config.doc_customer_attr] rescue ''
      due_date = Date.today + config.due_date.days

      params = {cedente: config.corporate_name,
                documento_cedente: config.document,
                cedente_endereco: config.address,
                sacado: self.customer_name,
                sacado_documento: doc_user,
                sacado_endereco: order.bill_address.full_address,
                numero_documento: document_number,
                data_vencimento: due_date,
                data_documento: Date.parse(created_at.to_s),
                valor: amount,
                aceite: config.acceptance,
                agencia: config.agency,
                conta_corrente: config.account,
                convenio: config.agreement,
                carteira: config.wallet,
                variacao: config.variation_wallet
      }
      (1..6).each { |cont| params["instrucao#{cont}".to_sym] = config["instruction_#{cont}"] }
      if config.bank == 'sicredi' then
        params.merge!({posto: config.office_code,
                       byte_idt: config.byte_idt})
      end

      document = case config.bank
                   when 'banco_brasil' then Brcobranca::Boleto::BancoBrasil.new params
                   when 'bradesco'     then Brcobranca::Boleto::Bradesco.new params
                   when 'caixa'        then Brcobranca::Boleto::Caixa.new params
                   when 'santander'    then Brcobranca::Boleto::Santander.new params
                   when 'itau'         then Brcobranca::Boleto::Itau.new params
                   when 'sicredi'      then Brcobranca::Boleto::Sicredi.new params
                   else
                  raise 'It is necessary set the billet config'
                 end
      document
    end

    # Return the amount converted to Money
    # according to currency
    #
    # copy of Spree::Payment.money
    #
    def money
      Spree::Money.new(amount, { currency: currency })
    end
    alias display_amount money

    # Returns the name of the customer according
    # to bill address of order
    #
    # @author Isabella Santos
    #
    # @return [String]
    #
    def customer_name
      "#{order.bill_address.firstname} #{order.bill_address.lastname}"
    rescue
      ''
    end

    # Returns if billet is paid
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def paid?
      status == 'paid'
    end

    # Returns if billet is pending
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def pending?
      status == 'pending'
    end

    # Returns if billet is waiting registry
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def waiting_registry?
      status == 'waiting_registry'
    end

    # Return if it is possible generate the document
    # (when status is waiting registry or pending)
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def can_generate_document?
      %w(waiting_registry pending).include?(status)
    end

    # Chanege the status to pending
    #
    # @author Isabella Santos
    #
    def to_pending!
      self.status = 'pending'
      self.save
    end

    def self.generate_shipping
      return {reason: :there_are_not_any_billets_to_registry, messages: []} if unregistered.empty?
      config = Spree::BilletConfig
      params = {empresa_mae: config.corporate_name,
                agencia: config.agency,
                conta_corrente: config.account,
                sequencial_remessa: config.shipping_number}
      document = case config.bank
                   when 'banco_brasil'
                     Brcobranca::Remessa::Cnab240::BancoBrasil.new(params.merge!({convenio: config.agreement,
                                                                                  carteira: config.wallet,
                                                                                  documento_cedente: config.document,
                                                                                  variacao: config.variation_wallet}))
                   when 'bradesco'
                     Brcobranca::Remessa::Cnab400::Bradesco.new(params.merge!({digito_conta: config.account_digit,
                                                                               carteira: config.wallet,
                                                                               codigo_empresa: config.company_code}))
                   when 'caixa'
                     Brcobranca::Remessa::Cnab240::Caixa.new(params.merge!({convenio: config.agreement,
                                                                            digito_conta: config.account_digit,
                                                                            documento_cedente: config.document,
                                                                            versao_aplicativo: config.app_version}))
                   when 'itau'
                     Brcobranca::Remessa::Cnab400::Itau.new(params.merge!({carteira: config.wallet,
                                                                           documento_cedente: config.document,
                                                                           digito_conta: config.account_digit}))
                   else
                     return {reason: :billet_bank_not_implemented, messages: []}
                 end
      document.pagamentos = []
      unregistered.each do |billet|
        next if billet.user.nil?
        doc_user = billet.user.attributes[config.doc_customer_attr] rescue ''
        user_address = billet.order.bill_address
        payment = Brcobranca::Remessa::Pagamento.new(valor: billet.amount,
                                                     data_vencimento: billet.due_date,
                                                     nosso_numero: billet.document_number,
                                                     documento_sacado: doc_user,
                                                     nome_sacado: billet.customer_name,
                                                     endereco_sacado: user_address.address1,
                                                     bairro_sacado: user_address.address2,
                                                     cep_sacado: user_address.zipcode,
                                                     cidade_sacado: user_address.city,
                                                     uf_sacado: user_address.state.abbr)
        document.pagamentos << payment
      end
      shipping = document.gera_arquivo
      if shipping.is_a? String
        config.shipping_number += 1
        # change the status of billets to pending
        unregistered.each { |billet| billet.to_pending! }
      end
      shipping
    rescue Brcobranca::RemessaInvalida => invalid
      {reason: :invalid_billets, messages: invalid.to_s.split(', ')}
    end
  end
end