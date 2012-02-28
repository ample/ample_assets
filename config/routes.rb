require 'ample_assets/devise_constraint'

AmpleAssets::Engine.routes.draw do

  # Require authentication when Devise is detected
  constraints(AmpleAssets::DeviseConstraint) do
    resources :files do
      member do
        post :touch
        post :gravity
      end
      collection do
        post :search
        get :recent
        AmpleAssets.allowed_mime_types.keys.each do |key|
          get key
        end
      end
    end
  end
  
  # This shouldn't be behind authentication
  match '/files/thumbs/:geometry' => AmpleAssets.dfly.endpoint { |params, app|
    AmpleAssets.dfly.fetch(params[:uid]).thumb(params[:geometry])
  }

end