module Spree
  class PaymentMethod::Billet < PaymentMethod

    def payment_source_class
      Spree::Billet
    end

    # Purchases the payment
    # saving the amount, document number (payment ID)
    # on source object (Spree::Billet)
    # This method is called when th payment method is set to auto capture
    # so, this will create the billet with status paid
    #
    # @author Isabella Santos
    #
    # @return [ActiveMerchant::Billing::Response]
    #
    def purchase(amount, source, *args)
      source.amount = amount.to_d / 100
      source.document_number = source.payment.id
      source.status = 'paid'

      source.payment.response_code = source.document_number
      ret = source.save

      ActiveMerchant::Billing::Response.new(ret, '', {}, authorization: source.document_number)
    end

    # Authorizes the payment
    # saving the amount, document number (payment ID)
    # on source object (Spree::Billet)
    #
    # @author Isabella Santos
    #
    # @return [ActiveMerchant::Billing::Response]
    #
    def authorize(amount, source, *args)
      source.amount = amount.to_d / 100
      source.document_number = source.payment.id

      ret = source.save

      ActiveMerchant::Billing::Response.new(ret, '', {}, authorization: source.document_number)
    end

    # Captures the payment
    # modifying the status and amount and saving the paid date
    # of the source (Spree::Billet)
    #
    # @author Isabella Santos
    #
    # @return [ActiveMerchant::Billing::Response]
    #
    def capture(amount, response_code, gateway_options)
      billet = Spree::Billet.find_by document_number: response_code
      billet.amount = amount.to_d / 100
      billet.paid_in = Date.today
      billet.status = 'paid'
      billet.save

      ActiveMerchant::Billing::Response.new(true, 'Billet Method: Successfully captured', {}, authorization: response_code)
    rescue
      ActiveMerchant::Billing::Response.new(false, 'Billet Method: Failed when try capture', {}, {})
    end

    # Voids the payment
    # modifying the status of the source (Spree::Billet)
    #
    # @author Isabella Santos
    #
    # @return [ActiveMerchant::Billing::Response]
    #
    def void(response_code, gateway_options)
      billet = Spree::Billet.find_by document_number: response_code
      billet.status = 'void'
      billet.save

      ActiveMerchant::Billing::Response.new(true, 'Billet Method: Successfully voided', {}, authorization: response_code)
    rescue
      ActiveMerchant::Billing::Response.new(false, 'Billet Method: Failed when try void', {}, {})
    end

    # Cancel the payment
    # modifying the status of the source (Spree::Billet)
    #
    # @author Isabella Santos
    #
    # @return [ActiveMerchant::Billing::Response]
    #
    def cancel(response_code)
      billet = Spree::Billet.find_by document_number: response_code
      billet.status = 'void'
      billet.save

      ActiveMerchant::Billing::Response.new(true, 'Billet Method: Successfully canceled', {}, authorization: response_code)
    rescue
      ActiveMerchant::Billing::Response.new(false, 'Billet Method: Failed when try cancel', {}, {})
    end
  end
end