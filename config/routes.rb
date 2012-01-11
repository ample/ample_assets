AmpleAssets::Engine.routes.draw do

  dfly = Dragonfly[:images]
  resources :files do
    member do
      post :touch
    end
    collection do
      post :search
      match 'recent', :to => "files#recent"
      match 'documents', :to => "files#documents"
      match 'images', :to => "files#images"
      match '/thumbs/:geometry' => dfly.endpoint { |params, app|
        dfly.fetch(params[:uid]).thumb(params[:geometry])
      }
    end
  end

end
