class UcbSecurity::RolesController < UcbSecurity::BaseController

  before_filter :init_role, :only => [:show, :edit, :update, :destroy]
  
  def index
    @roles = Role.find(:all, :order => 'name')
  end

  def show
  end

  def new
    @role = Role.new
  end

  def edit
  end

  def create
    @role = Role.new(params[:role])
    @role.save!
    flash[:notice] = 'Role was successfully created.'
    redirect_to(ucb_security_role_path(@role))
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = @role.errors.each_full {}.join('<br/>')
    render(:action => 'new')
  end

  def update
    @role.update_attributes!(params[:role])
    flash[:notice] = 'Role was successfully updated.'
    redirect_to(edit_ucb_security_role_path(@role))
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = @role.errors.each_full {}.join('<br/>')
    render :action => 'edit'
  end

  def destroy
    @role.destroy
    flash[:notice] = "Record was successfully deleted"
    redirect_to(ucb_security_roles_path())
  end
  
protected
  def init_role
    @role = Role.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Record Not Found"
    redirect_to(ucb_security_roles_path())
    return false
  end
end
