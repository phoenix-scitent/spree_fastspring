module Spree
  OrdersController.class_eval do
    before_filter :check_for_international, only: :edit
    
    def check_for_international
      @international = true if current_user && current_user.is_international?
    end
    
    def fastspring_complete
      return false if !params[:OrderID]
      return false if !params[:OrderReferrer]
      order = Spree::Order.find(params[:OrderReferrer])
      resp = PaymentMethod::FastSpring.get_order(params[:OrderID])
      if resp.status == "accepted" || resp.status == "completed"
        logger.debug("Accepted")
        order.update_attributes({
          state: "Completed",
          completed_at: Time.now,
          payment_state: "Completed",
          special_instructions: resp.reference
        })
        render :text => "Done" and return
      else
        render :text => "Bad" and return
      end
    end
    
    def test_fastspring
      uri = URI.parse("http://localhost:3000/fastspring/fastspring_complete")
      http = Net::HTTP.new(uri.host, uri.port)
      post_params = {"AddressStreet1"=>"373 Neff Avenue", "CustomerCompany"=>"", "CustomerLastName"=>"Hopkins", "OrderProductNames"=>"TestProduct", "OrderDiscountTotalUSD"=>"0.0", "OrderShippingTotalUSD"=>"0.0", "OrderIsTest"=>"true", "CustomerFirstName"=>"Kevin", "CustomerEmail"=>"sa.phx@scitent.com", "AddressRegion"=>"VA", "AddressPostalCode"=>"22801", "AddressStreet2"=>"", "AddressCity"=>"Harrisonburg", "OrderReferrer"=>"1", "OrderID"=>"SCI130208-9320-17125", "AddressCountry"=>"US", "CustomerPhone"=>"5403311772", "OrderSubTotalUSD"=>"10.0", "security_data"=>"1360359443021SCI130208-9320-17125sa.phx@scitent.com1360359443008", "security_hash"=>"e47e74ea2d6bce428588f039ac9756c3"}
      
      req = Net::HTTP::Post.new(uri.path)
      req.body = JSON.generate(post_params)
      req["Content-Type"] = "application/json"

      response = http.start {|htt| htt.request(req)}
      
      render text: response.inspect and return
    end
    
    def test_form
      
    end
  end
end