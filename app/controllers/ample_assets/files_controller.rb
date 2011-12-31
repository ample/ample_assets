module AmpleAssets
  class FilesController < ApplicationController
  
    def index
      render current_assets, :content_type => :html if request.xhr?
    end
    
    def new
      render 'ample_assets/files/new', :layout => false, :content_type => :html if request.xhr?
    end
    
    def create
      filename, filedata = params['Filename'], params['Filedata'] 
      file = File.new(:keywords => filename.gsub(/[^a-zA-Z0-9]/,' ').humanize, :attachment => filedata) 
      if file.save
        render file
      else 
        flash[:error] = "Whoops! There was a problem creating new asset."
        redirect_to :action => :index
      end
    end
    
    protected 
      
      helper_method :current_assets
      
      def current_assets
        @current_assets ||= File.all
      end
  
  end
end
