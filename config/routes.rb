AmpleAssets::Engine.routes.draw do

  resources :files do
    
    member do
      post :touch
      post :gravity
    end
    
    collection do
      post :search
      get :recent
      match '/thumbs/:geometry' => AmpleAssets.dfly.endpoint { |params, app|
        AmpleAssets.dfly.fetch(params[:uid]).thumb(params[:geometry])
      }
      AmpleAssets.allowed_mime_types.keys.each do |key|
        get key
      end
    end
    
  end

end