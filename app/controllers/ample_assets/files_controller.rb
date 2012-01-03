module AmpleAssets
  class FilesController < ApplicationController
  
    def index
      render current_files, :content_type => :html if request.xhr?
    end

    def recent
      respond_to do |format|
        format.js { render recent_files, :content_type => :html }
        format.html { render :template => 'ample_assets/files/recent', :content_type => :html }
        format.json { render :json => recent_files.to_json }
      end
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
      
      helper_method :current_files, :recent_files
      
      def current_files
        @current_files ||= File.all
      end
      
      def recent_files
        @recent_files ||= File.recent
      end
  
  end
end
