module AmpleAssets
  class FilesController < ApplicationController
  
    def index
      if request.xhr?
        render current_assets, :content_type => :html
      end
    end
  
    protected 
      
      helper_method :current_assets
      
      def current_assets
        @current_assets ||= File.all
      end
  
  end
end
