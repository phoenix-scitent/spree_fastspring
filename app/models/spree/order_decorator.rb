Spree::Order.class_eval do
  attr_accessible :state, :completed_at, :payment_state, :user_id
end