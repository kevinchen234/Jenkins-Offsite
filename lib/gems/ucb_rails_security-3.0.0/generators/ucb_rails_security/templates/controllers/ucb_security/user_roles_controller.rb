class UcbSecurity::UserRolesController < UcbSecurity::BaseController

    before_filter :load_user

    def edit
      @roles = Role.find(:all, :order => 'name')
    end

    def update
      params[:user] ||= {}
      params[:user][:role_ids] ||= []

      @user.update_attributes!(params[:user])
      flash[:notice] = 'User roles were successfully updated.'
      redirect_to(edit_ucb_security_user_roles_path(@user))
    rescue ActiveRecord::RecordInvalid
      @roles = Role.find(:all, :order => 'name')
      flash.now[:error] = @user.errors.each_full {}.join('<br/>')
      render(:action => 'edit')
    end

  protected
    def load_user
      @user = User.find(params[:user_id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Record Not Found"
      redirect_to(ucb_security_users_path())
    end
end
