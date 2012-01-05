AmpleAssets::Engine.routes.draw do

  resources :files do
    collection do
      match 'recent', :to => "files#recent"
    end
  end

end
