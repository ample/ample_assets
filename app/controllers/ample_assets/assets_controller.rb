module AmpleAssets
  class AssetsController < ApplicationController
  
    def index
      if request.xhr?
        render current_assets, :content_type => :html
      end
    end
  
    protected 
      
      helper_method :current_assets
      
      def current_assets
        @current_assets ||= Asset.all
      end
  
  end
end
