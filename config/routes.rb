ActionController::Routing::Routes.draw do |map|
  map.resources :packages

  # map.root :controller => "welcome"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
