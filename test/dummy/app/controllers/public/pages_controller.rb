class Public::PagesController < PublicController

  def create
    @current_page = Page.new page_params
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
      @current_page ||= params[:id] ? Page.find(params[:id]) : Page.new
    end

    def page_params
      params.require(:page).permit(:title)
    end

end
