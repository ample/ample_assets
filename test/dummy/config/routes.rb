Rails.application.routes.draw do

  mount AmpleAssets::Engine => "/ample_assets", :as => "ample_assets"
  root :to => 'public#index'

end
