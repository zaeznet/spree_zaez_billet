class Spree::Admin::BilletsController < Spree::Admin::BaseController

  def shipping
    @billets = Spree::Billet.unregistered
  end

  def register
    shipping = Spree::Billet.generate_shipping
    if shipping.is_a? String
      # formats the name of the file
      name = ''
      name << 'C' + Spree::BilletConfig.bank[0].upcase
      name << Date.today.day.to_s.rjust(2, '0')
      name << Date.today.month.to_s.rjust(2, '0')
      name << SecureRandom.hex(1).upcase
      name

      send_data shipping, :content_type => 'text/plain', :filename => "#{name}.rem"
    else
      flash[:error] = Spree.t("errors.#{shipping[:reason]}")
      redirect_to :admin_billets_shipping
    end
  end

  def return
  end

  def return_info
    data = case params[:file_type].to_sym
             when :cnab240 then Brcobranca::Retorno::RetornoCnab240.load_lines params[:file].path
             when :cnab400 then Brcobranca::Retorno::RetornoCnab400.load_lines params[:file].path
             when :cbr643  then Brcobranca::Retorno::RetornoCbr643.load_lines params[:file].path
           end

    @lines = []
    data.each do |line|
      # se for o registro trailer passa para a proxima iteracao
      next if line == data.last
      payment = Spree::Payment.find_by id: line.nosso_numero

      if payment and line.valor_recebido.to_i > 0 and !(payment.completed? or payment.void?)
        amount_paid = line.valor_recebido.to_f + line.valor_tarifa.to_f
        payment.capture! amount_paid

        # formats the date
        year = line.data_credito.size == 6 ? line.data_credito : "20#{line.data_credito}"
        paid_at = "#{year}#{line.data_credito[2..3]}#{line.data_credito[0..1]}".to_date
        # formats the value
        value = (line.valor_titulo.to_f / 100) + (line.valor_tarifa.to_f / 100)

        @lines.push({document_number: line.nosso_numero,
                     value: Spree::Money.new(value, { currency: payment.currency }),
                     paid_at: paid_at,
                     order_id: payment.order_id,
                     order_number: payment.order.number})
      end
    end
  rescue
    flash[:error] = Spree.t('errors.error_in_billets_return')
  end

  private

  def model_class
    Spree::BilletsController
  end

end