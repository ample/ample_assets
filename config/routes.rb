AmpleAssets::Engine.routes.draw do

  dfly = Dragonfly[:images]
  resources :files do
    collection do
      match 'recent', :to => "files#recent"
      match '/thumbs/:geometry' => dfly.endpoint { |params, app|
        dfly.fetch(params[:uid]).thumb(params[:geometry])
      }
    end
  end

end
