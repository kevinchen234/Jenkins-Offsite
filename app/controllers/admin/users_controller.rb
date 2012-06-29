class Admin::UsersController < Admin::AdminController
  before_filter :major_tab_users
  before_filter :minor_tab_users  
  before_filter :load_roles, :except => [:index, :destroy, :login]
  before_filter :load_user, :only => [:update, :edit, :destroy, :login]
  
  def index
    @users = User.find_from_filter(params[:filter_by])
    @filter_by_options = User.filter_by_options
  end

  def new
    #@user = User.new_from_ldap_uid(params[:ldap_uid])  #nothing in params so this will give an error
    @user = User.new_from_ldap_uid(ldap_user.uid)
  end

  def edit
  end
  
  def create
    @user = User.new_from_attr_hash(params[:user])
    @user.save!
    flash[:notice] = msg_created(@user)
    redirect_to(edit_admin_user_url(@user))
  rescue ActiveRecord::RecordInvalid
    render("new")
  end

  def update
    params[:user][:role_ids] ||= []
    @user.ldap_uid = params[:user][:ldap_uid]
    @user.role_ids = params[:user][:role_ids]
    @user.enabled = params[:user][:enabled]

    @user.update_attributes!("first_name"=>params[:user][:first_name], "last_name"=>params[:user][:last_name],
                             "email"=>params[:user][:email], "department"=>params[:user][:department])
    flash[:notice] = msg_updated(@user)
    redirect_to(edit_admin_user_url(@user))
  rescue ActiveRecord::RecordInvalid
    render("edit")
  end
  
  def destroy
    if @user.destroy
      flash[:notice] = msg_destroyed(@user)
      redirect_to(admin_users_url)
    else
      flash[:error] = msg_errors(@user).join("<br/>")
      redirect_to(edit_admin_user_url(@user))      
    end
  end
  
  def login
    application_login(@user.ldap_uid)
    redirect_to root_url
  end

  
  protected
  
  def load_user
    @user = User.find(params[:id])
  end
  
  def load_roles
    @all_roles = Role.all
  end
  
end
