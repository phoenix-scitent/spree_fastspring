require 'httparty' unless defined?(HTTParty)
require 'active_support/builder' unless defined?(Builder)
class FsprgOrder
  attr_accessor :status, :status_changed, :status_reason, :cancelable, :reference, :test
  attr_accessor :customer, :customer_url, :next_period_date, :end_date, :line_items
end

class FsprgException < RuntimeError
  def initialize(http_status_code, error_code)
    @http_status_code = http_status_code
    @error_code = error_code
  end
  
  def http_status_code
    @http_status_code
  end
  
  def error_code
    @error_code
  end
end

class FsprgCustomer
  attr_accessor :first_name, :last_name, :company, :email, :phone_number
end

class PaymentMethod::Fastspring < Spree::PaymentMethod
  attr_accessible :preferred_company, :preferred_password, :preferred_username
      
  preference :company, :string
  preference :username, :string
  preference :password, :string
      
  def self.set_auth
    m = Spree::PaymentMethod.find_by_type("PaymentMethod::FastSpring")
    @auth = {
      username: m.preferences[:username],
      password: m.preferences[:password],
      store_id: m.preferences[:company]
    }
  end
      
  @test_mode = false

  def self.test_mode?
    @test_mode
  end

  def self.test_mode=(mode)
    @test_mode = true
  end

  def self.add_test_mode(url)
    if @test_mode
      if url.include? "?"
        url = url << "&mode=test"
      else
        url = url << "?mode=test"
      end
    end
    url
  end
      
  def self.get_order(order_ref)
    set_auth
    url = orders_url(order_ref)
    puts "Sending to #{url}"
    options = { :basic_auth => @auth }
    response = HTTParty.get(url, options)
    puts "Response: #{response.inspect}"
    if response.code == 200
      order = parse_order(response.parsed_response.fetch('order'))
    else
      exception = FsprgException.new(response.code, nil)
      raise exception, "An error occurred calling the FastSpring order service", caller
    end

    order
  end
      
  def self.orders_url(reference, *options)
    url = "https://api.fastspring.com/company/#{@auth[:store_id]}/order/#{reference}"

    unless options.nil? || options.length == 0
      opt = options[0]
      if opt.has_key?(:postfix)
        url = url << opt[:postfix]
      end
      if opt.has_key?(:params)
        params = opt[:params]
        if params.length > 0
          url = url << "?"
        end
        params.each do |param|
          url = url << param
        end
      end
    end

    url = add_test_mode(url)
  end
  
  def self.product_add_url
    set_auth
    url = "https://sites.fastspring.com/#{@auth[:store_id]}/api/order"
  end

  def self.parse_order(response)
    order = FsprgOrder.new

    order.status = response.fetch('status', 'error')
    status_changed = response.fetch("statusChanged", nil)
  
    if not status_changed.nil?
      order.status_changed = Date.parse(status_changed)
    end
  
    order.status_reason = response.fetch("statusReason", nil)
    order.cancelable = response.fetch("cancelable", nil)
    order.reference = response.fetch("reference", nil)
    order.test = response.fetch("test", nil)
    order.line_items = response.fetch("orderItems", nil).fetch("orderItem", nil)

    customer = FsprgCustomer.new;
    custResponse = response.fetch("customer")

    customer.first_name = custResponse.fetch("firstName", nil)
    customer.last_name = custResponse.fetch("lastName", nil)
    customer.company = custResponse.fetch("company", nil)
    customer.email = custResponse.fetch("email", nil)
    customer.phone_number = custResponse.fetch("phoneNumber", nil)

    order.customer = customer;

    order.customer_url = response.fetch("customerUrl", nil)
    next_period_date = response.fetch("nextPeriodDate", nil)
    if not next_period_date.nil?
      order.next_period_date = Date.parse(next_period_date)
    end
    end_date = response.fetch("end", nil)
    if not end_date.nil?
      order.end_date = Date.parse(end_date)
    end

    order
  end
end