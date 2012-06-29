class Admin::ExtCircumstancesController < Admin::AdminController
  before_filter :major_tab_ext_circumstances
  before_filter :load_ext_circumstance, :only => [:edit, :update, :destroy]
  
  def index
    @circumstances = ExtCircumstance.all
  end

  def new
    @ext_circumstance = ExtCircumstance.new
  end

  def edit
  end

  def create
    @ext_circumstance = ExtCircumstance.new(params[:ext_circumstance])
    if @ext_circumstance.save
      flash[:notice] = msg_created(@ext_circumstance)
      redirect_to admin_ext_circumstances_url
    else
      render("new")
    end
  end

  def update
    if @ext_circumstance.update_attributes(params[:ext_circumstance])
      flash[:notice] = msg_updated(@ext_circumstance)
      redirect_to admin_ext_circumstances_url
    else
      render("edit")
    end
  end

  def destroy
    begin
      if @ext_circumstance.destroy
        flash[:notice] = msg_destroyed(@ext_circumstance)
      else
        flash[:error] = msg_errors(@ext_circumstance).join("<br/>")
      end
    rescue DestroyWithReferencesError
      flash[:error] = ["Tried to delete an Extenuating Circumstance that is referenced by an Off Site Request."]
    end
    redirect_to admin_ext_circumstances_url
  end
  
  
  protected
  
  def load_ext_circumstance
    @ext_circumstance = ExtCircumstance.find(params[:id])
  end

end
