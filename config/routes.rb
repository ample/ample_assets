AmpleAssets::Engine.routes.draw do

  resources :files
  root :to => "files#index"

end
