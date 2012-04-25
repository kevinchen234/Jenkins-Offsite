class UcbSecurity::RoleUsersController < UcbSecurity::BaseController

  before_filter :load_role
  
  def edit
    @unassociated_users = @role.non_users_menu_list()
    @associated_users = @role.users_menu_list()
  end

  def update
    @role.update_attributes(:user_ids => params[:user_ids])
    @role.save!
    flash[:notice] = "Role users were successfully updated."
    redirect_to(edit_ucb_security_role_users_path(@role))
  rescue ActiveRecord::RecordInvalid
    flash[:error] = @role.errors.each_full {}.join('<br/>')
    render :action => 'edit'
  end

protected
  def load_role
    @role = Role.find(params[:role_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Record Not Found"
    redirect_to(ucb_security_roles_url)
  end
end
