AmpleAssets::Engine.routes.draw do

  resources :files do
    collection do
      match 'recent', :to => "files#recent"
    end
  end
  root :to => "files#index"

end
