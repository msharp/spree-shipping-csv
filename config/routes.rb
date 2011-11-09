
Rails.application.routes.draw do
  #resources :shippingdocs
  match 'admin/shippingdocs', :to => 'admin/shippingdocs#index'
end
