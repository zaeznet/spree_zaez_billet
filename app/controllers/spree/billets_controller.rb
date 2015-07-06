class Spree::BilletsController < Spree::StoreController

  before_action :load_data, only: :show

  def show
    if @billet.due_date.past?
      # voids the old payment
      old_payment = @billet.payment
      old_payment.void_transaction!

      # creates the new payment
      params = {order: @billet.order,
                amount: old_payment.amount,
                payment_method: @billet.payment_method,
                source_attributes: {order: @billet.order,
                                    user: @billet.user,
                                    status: 'pending'}}
      new_payment = Spree::Payment.new(params)
      new_payment.pend!
      new_payment.process!

      @billet = new_payment.source
    end
    # generate the billet document
    @document = @billet.generate_document
    send_data @document.to_pdf, filename: "boleto_#{@billet.order.number}.pdf"
  end

  private

  def load_data
    @billet = Spree::Billet.find params[:id] || params[:billet_id]
  end

end