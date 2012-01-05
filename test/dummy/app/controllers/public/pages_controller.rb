class Public::PagesController < PublicController
  
  def index
  end
  
  def new
  end
  
  def create
    @current_page = Page.new params[:page]
    if @current_page.save
      flash[:notice] = "Page saved!"
      redirect_to :action => :index
    else
      flash[:error] = "There was a problem"
    end
  end
  
  def update
    if current_page.update_attributes(params[:page])
      flash[:notice] = "Page updated!"
      redirect_to :action => :index
    else
      flash[:error] = "There was a problem"
      render :action => :edit
    end

  end
  
  protected 
  
    helper_method :current_page
    
    def current_page
      @current_page ||= Page.find params[:id]
    end

end