module PaymentHelper
    def getRazorpayOrderId(currency, amount, receipt_id)
        key_id = Rails.configuration.payment['key_id']
        secret = Rails.configuration.payment['secret']
        url = Rails.configuration.payment['url']
        razorpay_order_id = nil
        order = Order.new
        razorpay_record = Razorpay.new
        razorpay_record.order = order
        razorpay_record.save
        order.save
        begin
            order_response = HTTP.basic_auth(:user => key_id, :pass => secret)
                .post(url, :json => 
                    { "amount" => amount, "currency" => currency, "receipt" => order.id.to_s, "payment_capture" => '1' })
            
            logger.info "Received from razorpay #{order_response.to_s}"
            if order_response.status == 200 
                order_info = JSON.parse(order_response.to_s)
                razorpay_order_id = order_info["id"]
                razorpay_record.update(o_id: razorpay_order_id)
                logger.info "Processed #{razorpay_order_id}"
            end
        rescue Exception => ex
            logger.error "Error in getting razorpay order id: #{ex.message}"
            logger.error  ex.backtrace.join("\n")
        end
        razorpay_order_id
    end
end