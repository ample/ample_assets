AmpleAssets::Engine.routes.draw do

  resources :assets
  root :to => "assets#index"

end
