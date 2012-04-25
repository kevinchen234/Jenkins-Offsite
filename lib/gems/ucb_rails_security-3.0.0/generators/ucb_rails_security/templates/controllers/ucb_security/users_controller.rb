class UcbSecurity::UsersController < UcbSecurity::BaseController
  before_filter :init_user, :only => [:show, :edit, :update, :destroy]
  
  def index
    @users = User.find(:all, :order => "last_name, first_name")
  end

  def show
  end

  def new
    @user = User.new_from_ldap_uid(params[:ldap_uid])
  rescue UCB::LDAP::Person::RecordNotFound => e
    flash[:error] = e.message
    redirect_to(ucb_security_users_path())
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    @user.save!
    flash[:notice] = 'User was successfully created.'
    redirect_to(ucb_security_user_path(@user)) 
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = @user.errors.each_full {}.join('<br/>')
    render(:action => 'new')
  end

  def update
    @user.update_attributes!(params[:user])
    flash[:notice] = 'User was successfully updated.'
    redirect_to(edit_ucb_security_user_path(@user))
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = @user.errors.each_full {}.join('<br/>')
    render(:action => 'edit')
  end

  def destroy
    if @user.current_user?(ldap_uid())
      flash[:error] = "You cannot delete yourself!"
      redirect_to(ucb_security_users_path()) and return nil
    else
      @user.destroy
      flash[:notice] = "User was successfully destroyed"
      redirect_to(ucb_security_users_path())
    end    
  end
  
protected
  def init_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Record Not Found"
    redirect_to(ucb_security_users_path())
  end

end
