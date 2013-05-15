module AmpleAssets
  class FilesController < ApplicationController

    ([:index, :recent] | AmpleAssets.allowed_mime_types.keys).compact.each do |key|
      define_method key do
        respond_to do |format|
          format.js   { render current_files, :content_type => :html }
          format.json { render :json => current_files.to_json }
          format.html
        end
      end
    end

    def new
      render 'ample_assets/files/new', :layout => false, :content_type => :html if request.xhr?
    end

    def create
      if uploadify?
        filename, filedata = params['Filename'], params['Filedata']
        file = File.new(:attachment => filedata)
      else
        file = File.new(params[:file])
      end
      if file.save
        if uploadify?
          render :nothing => true
        else
          redirect_to file_path(file)
        end
      else
        flash[:error] = "Whoops! There was a problem creating new asset."
        redirect_to :action => :index
      end
    end

    def show
      raise ActiveRecord::RecordNotFound if current_file.nil?
      respond_to do |format|
        format.json { render :json => current_file.to_json }
        format.html
      end
    end

    def destroy
      current_file.destroy
      if request.xhr?
        render :nothing => true
      else
        flash[:notice] = 'Asset deleted successfully.'
        redirect_to request.referrer
      end
    end

    def touch
      raise ActiveRecord::RecordNotFound if current_file.nil?
      current_file.touch
      render :nothing => true
    end

    def gravity
      raise ActiveRecord::RecordNotFound if current_file.nil?
      current_file.update_attribute :attachment_gravity, params[:gravity]
      render :nothing => true
    end

    def search
      @current_files = File.with_query("^#{params[:q]}")
      respond_to do |format|
        format.js { render current_files, :content_type => :html }
        format.json { render :json => current_files.to_json }
        format.html { render :nothing => true }
      end
    end

    protected

      helper_method :current_files, :recent_files, :current_file

      def current_files
        conditions = current_mime_types.keys.include?(params[:action].intern) ? current_file_conditions : nil
        pagination = { :page => params[:page], :per_page => per_page }
        @current_files ||= File.find(:all, :conditions => conditions, :order => 'created_at DESC').paginate(pagination)
      end

      def current_file_conditions
        are = params[:type] == 'documents' ? 'NOT in' : 'in'
        type = params[:action].intern
        [ "attachment_mime_type #{are} (?)", current_mime_types[type] ]
      end

      def recent_files
        @recent_files ||= File.recent.paginate(:page => params[:page], :per_page => per_page)
      end

      def per_page
        params[:per_page] || 20
      end

      def current_file
        @current_file ||= File.find params[:id]
      end

      def uploadify?
        params['Filename'] && params['Filedata']
      end

      # TODO Well thats obxoxious.
      #
      #      I'm falling back to the default configuration constant here because
      #      functional tests aren't seeing the engine's default allowed_mime_types
      #      value. Any ideas?
      #
      def current_mime_types
        @current_mime_types ||= begin
          if AmpleAssets.allowed_mime_types.respond_to?(:keys)
            AmpleAssets.allowed_mime_types
          else
            AmpleAssets::Configuration::DEFAULT_ALLOWED_MIME_TYPES
          end
        end
      end

  end
end
