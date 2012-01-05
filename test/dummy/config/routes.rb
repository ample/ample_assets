Rails.application.routes.draw do

  mount AmpleAssets::Engine => "/ample_assets", :as => "ample_assets"

  resources :pages, :to => 'public/pages'
  root :to => 'public#index'

end
