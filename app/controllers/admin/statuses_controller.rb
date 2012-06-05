class Admin::StatusesController < Admin::AdminController
  before_filter :major_tab_status
  before_filter :load_status, :only => [:edit, :update, :destroy]
  
  def index
    @statuses = Status.all
  end

  def new
    @status = Status.new
  end

  def edit
  end

  def create
    @status = Status.new(params[:status])
    if @status.save
      flash[:notice] = msg_created(@status)
      redirect_to(admin_statuses_url)
    else
      render("new")
    end
  end

  def update
    if @status.update_attributes(params[:status])
      flash[:notice] = msg_updated(@status)
      redirect_to(admin_statuses_url)
    else
      render("edit")
    end
  end

  protected
  
  def load_status
    @status = Status.find(params[:id])
  end
end
