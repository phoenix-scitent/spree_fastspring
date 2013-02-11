Rails.application.routes.draw do
  match '/fastspring/fastspring_complete', controller: "Spree::Orders", action: :fastspring_complete
  match "/fastspring/test_fastspring", controller: "Spree::Orders", action: :test_fastspring
  match '/fastspring/test_form', controller: "Spree::Orders", action: :test_form
end