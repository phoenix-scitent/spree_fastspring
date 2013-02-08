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
      resp = Spree::Gateway::FastSpring.get_order(params[:OrderID])
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
      uri = URI.parse("http://localhost:3000/fastspring_complete")
      http = Net::HTTP.new(uri.host, uri.port)
      post_params = {}
      
      req = Net::HTTP::Post.new(uri.path)
      req.body = JSON.generate(post_params)
      req["Content-Type"] = "application/json"

      response = http.start {|htt| htt.request(req)}
      
      render text: response.inspect and return
    end
  end
end