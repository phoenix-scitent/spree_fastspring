Spree::Core::Engine.routes.draw do
  match '/fastspring_complete' => "orders#fastspring_complete"
  match "/test_fastspring" => "orders#test_fastspring"
end