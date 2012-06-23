class Admin::RolesController < Admin::AdminController
  #before_filter :major_tab_roles
  before_filter :load_users, :except => [:index, :destroy]
  before_filter :load_role, :only => [:edit, :update, :destroy]
  
  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def edit
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = msg_created(@role)
      redirect_to admin_roles_url
    else
      render("new")
    end
  end

  def update
    if @role.update_attributes(params[:role])
      flash[:notice] = msg_updated(@role)
      redirect_to admin_roles_url
    else
      render("edit")
    end
  end

  def destroy
    if @role.destroy
      flash[:notice] = msg_destroyed(@role)
    else
      flash[:error] = msg_errors(@role)
    end
    redirect_to admin_roles_url
  end

  protected
  
  def load_role
    @role = Role.find(params[:id])
  end

  def load_users
    @all_users = User.all
  end
end
