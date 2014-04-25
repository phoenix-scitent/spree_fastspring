Rails.application.routes.draw do
  match '/fastspring/fastspring_complete', controller: "Spree::Orders", action: :fastspring_complete, via: [:post]
  match "/fastspring/test_fastspring", controller: "Spree::Orders", action: :test_fastspring, via: [:post]
  match '/fastspring/test_form', controller: "Spree::Orders", action: :test_form
end
