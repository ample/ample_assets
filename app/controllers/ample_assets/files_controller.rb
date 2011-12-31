module AmpleAssets
  class FilesController < ApplicationController
  
    def index
      render current_assets, :content_type => :html if request.xhr?
    end
    
    def new
      render 'ample_assets/files/new', :layout => false, :content_type => :html if request.xhr?
    end
    
    protected 
      
      helper_method :current_assets
      
      def current_assets
        @current_assets ||= File.all
      end
  
  end
end
