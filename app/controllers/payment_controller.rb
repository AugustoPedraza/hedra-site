class PaymentController < ApplicationController
  layout "application"

  skip_before_filter :verify_authenticity_token, :only => [:callback_9E93257460]

  def credit_card
    if session[:carrinho].nil? 
      redirect_to cart_url, :alert => "Não foi possível finalizar a sua compra, pois não há itens no seu carrinho de compras."
      return
    end

    @address = Address.find(session[:address_id])
    @order = create_order(current_user, @address, session[:carrinho], Transaction::CREDIT_CARD)

    Iugu.api_key = APP_CONFIG["iugu_api_key"]
    iugu_charge = Iugu::Charge.create({ token: params[:token], email: current_user.email, items: @order.order_items_to_iugu } )

    @transaction = @order.transactions.last
    @transaction.customer_ip = request.ip,
    @transaction.payment_status = Transaction::PENDING
    @transaction.invoice_id = iugu_charge.invoice_id
    @transaction.save

    if iugu_charge.invoice.status == Transaction::PAID
      session[:carrinho] = nil
      render :template => "checkout/review"
      return
    else
      redirect_to cart_url, :alert => "Não foi possível finalizar a sua compra, #{iugu_charge.message}"
      return
    end 

  end


  def bank_slip
    if session[:carrinho].nil? 
      redirect_to cart_url, :alert => "Não foi possível finalizar a sua compra, pois não há itens no seu carrinho de compras."
      return
    end

    @address = Address.find(session[:address_id])
    @order = create_order(current_user, @address, session[:carrinho], Transaction::BANK_SLIP)
    Iugu.api_key = APP_CONFIG["iugu_api_key"]

    iugu_charge = Iugu::Charge.create({
      method: "bank_slip",
      email: current_user.email,
      items: @order.order_items_to_iugu,
      payer: {
        cpf_cnpj: params[:cpf_cnpj],
        name: params[:client_name],
        phone_prefix: params[:phone_prefix],
        phone: params[:phone],
        email: current_user.email,
        address: {
            street: params[:street],
            number: params[:number],
            city: params[:city],
            state: params[:state],
            country: "Brasil",
            zip_code: params[:zip_code]
        }
      }
    })

    @transaction = @order.transactions.last
    @transaction.customer_ip = request.ip,
    @transaction.invoice_id = iugu_charge.invoice_id
    @transaction.payment_status = Transaction::PENDING
    @transaction.save

    if iugu_charge.success
      session[:carrinho] = nil
      render :template => "checkout/review"
      return
    else
      redirect_to cart_url, :alert => "Não foi possível finalizar a sua compra"
      return
    end 

  end

=begin 
  make the name hard to guest for security
  test in dev:
  $.ajax({
   type: "POST",
   url: "/payment/callback_9E93257460",
   data:  JSON.stringify ({"event": "invoice.status_changed", "data": {"id": "9D92C9E932574604ADD10D327C60D24E", "status": "paid"}}),
   contentType: "application/json; charset=utf-8",
   dataType: "json"
  });
=end 
  def callback_9E93257460

    if params[:event] != "invoice.status_changed"
      render text: "event does not match"
      return
    end

    transaction = Transaction.find_by_invoice_id(params[:data][:id])

    if transaction.nil?
      render text: "invoice not found"
      return
    end

    transaction.payment_status = params[:data][:status]

    if transaction.payment_status == Transaction::PAID
      transaction.status = Transaction::COMPLETED
    elsif transaction.payment_status == Transaction::CANCELED or transaction.payment_status == Transaction::EXPIRED
      transaction.status = Transaction::FAILED
    end

    transaction.save

    render text: "ok"
  end

end

