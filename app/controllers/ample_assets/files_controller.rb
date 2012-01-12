module AmpleAssets
  class FilesController < ApplicationController
  
    def index
      render_collection(current_files)
    end
    
    def recent
      render_collection(recent_files)
    end
    
    def documents
      render_collection(current_documents)
    end
    
    def images
      render_collection(current_images)
    end
    
    def render_collection(collection)
      respond_to do |format|
        format.js { render collection, :content_type => :html }
        format.json { render :json => collection_to_json(collection) }
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
      raise ActiveRecord::RecordNotFound if current_file.nil?
      respond_to do |format|
        format.json { render :json => current_file.json }
        format.html
      end
    end
    
    def touch
      raise ActiveRecord::RecordNotFound if current_file.nil?
      current_file.touch
      render :nothing => true
    end
    
    def search
      @current_files = File.with_query(params[:q])
      respond_to do |format|
        format.js { render current_files, :content_type => :html }
        format.json { render :json => collection_to_json(current_files) }
        format.html { render :nothing => true }
      end
    end
    
    protected 
      
      helper_method :current_files, :recent_files, :current_file
      
      def current_files
        conditions = params[:type] ? current_file_conditions : nil
        pagination = { :page => params[:page], :per_page => per_page }
        @current_files ||= File.find(:all, :conditions => conditions).paginate(pagination)
      end
      
      def current_documents
        params[:type] = 'documents'
        current_files
      end
      
      def current_images
        params[:type] = 'images'
        current_files
      end
      
      def current_file_conditions
        are = params[:type] == 'documents' ? 'NOT in' : 'in'
        [ "attachment_mime_type #{are} (?)", AmpleAssets::Engine.config.allowed_mime_types[:images] ]
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
