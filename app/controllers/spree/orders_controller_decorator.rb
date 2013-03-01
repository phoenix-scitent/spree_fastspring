module Spree
  OrdersController.class_eval do
    before_filter :allow_fastspring, only: :edit
    
    def allow_fastspring
      @use_fastspring = current_user && current_user.should_checkout_with_fastspring?
    end
    
    def fastspring_complete
      return false if !params[:OrderID]
      return false if !params[:OrderReferrer]
      order = Spree::Order.find(params[:OrderReferrer])
      user = User.find_by_email(params[:CustomerEmail])
      resp = ::PaymentMethod::Fastspring.get_order(params[:OrderID])
      if resp.status == "accepted" || resp.status == "completed"
        order.update_attributes({
          special_instructions: resp.reference,
          user_id: (user.id rescue nil)
        })
        EcommerceApi.process_purchase(order)
        order.line_items.each do |li|
          Spree::Adjustment.create({
            source_id: li.id,
            amount: (li.price * -1),
            label: "Paid via FastSpring: #{resp.reference}",
            adjustable_id: li.id,
            adjustable_type: "Spree::LineItem",
            payment_state: "completed"
          })
          
        order.state_changes.create({
          :previous_state => 'cart',
          :next_state     => 'complete',
          :name           => 'order' ,
          :user_id        => order.user_id
        }, :without_protection => true)
        end
        
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
