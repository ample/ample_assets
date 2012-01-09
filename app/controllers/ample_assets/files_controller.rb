module AmpleAssets
  class FilesController < ApplicationController
  
    def index
      respond_to do |format|
        format.js { render current_files, :content_type => :html }
        format.json { render :json => collection_to_json(current_files) }
        format.html { render :nothing => true }
      end
    end

    def recent
      respond_to do |format|
        format.js { render recent_files, :content_type => :html }
        format.json { render :json => recent_files_json }
        format.html { render :nothing => true }
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
    
    def show
    end
    
    protected 
      
      helper_method :current_files, :recent_files, :current_file
      
      def current_files
        @current_files ||= File.find(:all).paginate(:page => params[:page], :per_page => per_page)
      end
      
      def recent_files
        @recent_files ||= File.recent.paginate(:page => params[:page], :per_page => per_page)
      end
      
      def recent_files_json
        @recent_files_json ||= recent_files.collect{ |file| file.json }.to_json
      end

      def collection_to_json(collection)
        collection.collect{ |file| file.json }.to_json
      end
      
      def per_page
        params[:per_page] || 20
      end
      
      def current_file
        @current_file ||= File.find params[:id]
      end
      
  end
end
