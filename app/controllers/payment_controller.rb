require 'json'

class PaymentController < ApplicationController
    include PaymentHelper
    skip_before_action :verify_authenticity_token

    def show
        currency = params[:currency]
        amount = params[:amount]
        receipt_id = params[:receipt_id]
        logger.info "#{currency.present?} #{amount.present?}"
        if !(currency.present? && amount.present? && receipt_id.present?)
            render :json => {:success => false, :message => "Invalid parameters"}.to_json, :status => 400
            return
        end
        logger.info "Processing payment for currency #{currency} amount #{amount} receipt_id #{receipt_id}" 
        @order_id = helpers.getRazorpayOrderId(currency, amount, receipt_id)
        logger.info "Razorpay order_id #{@order_id}"
        if @order_id == nil
            logger.error "Got nil for getting razorpayOrderId for receipt_id #{receipt_id}"
            render :json => {:success => false}.to_json, :status => 500
        end
    end

    def post
        razorpay_payment_id = params[:razorpay_payment_id]
        razorpay_order_id = params[:razorpay_order_id]
        razorpay_signature = params[:razorpay_signature]
        
        logger.info "Processing razorpay callback for #{razorpay_order_id}"
        secret = Rails.configuration.payment['secret']
        verification_string = razorpay_order_id + "|" + razorpay_payment_id
        hexdigest = OpenSSL::HMAC.hexdigest("SHA256", secret, verification_string)
        if hexdigest != razorpay_signature
            logger.error "The signatures did not match, aborting the transaction for order_id #{razorpay_order_id}"
            render json => {:success => false}.to_json, :status => 500
            return
        end

        razorpay_record =  Razorpay.find_by o_id: razorpay_order_id
        if razorpay_record ==  nil
            logger.error "Error in processing callback Order id #{razorpay_order_id} not found"
            render :json => {:success => false}.to_json, :status => 500
            return
        end

        payment = Paymnt.new
        razorpay_record.update(payment_id: razorpay_payment_id)
        payment.payable = razorpay_record
        payment.order = razorpay_record.order
        payment.save
        logger.info "Successful razorpay order #{razorpay_order_id}"  
        render :json => {:success => true}.to_json, :status => 200
    end
end