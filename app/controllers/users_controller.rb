class UsersController < ApplicationController
  #before_filter :filter_logged_in
  before_filter :ensure_authenticated_user
  before_filter :deny_if_user_exists
  #before_filter :major_tab_off_site_requests doesn't exist


  #### Test spec finished? ####


  def new
    @user = User.new_from_ldap_uid(ldap_user.uid)
  end

  def create
    @user = User.new(params[:user])
    @user.ldap_uid = ldap_user.uid
    @user.enabled = true
    if @user.save
      flash[:notice] = "Your information was successfully updated."
      if application_login(@user.ldap_uid) #this method also redirects. Decide which one to keep
        redirect_to off_site_requests_url
      else
        redirect_to not_authorized_url
      end
    else
      render("new")
    end
  end

  protected

  ##
  # If the user already exists in the user table they should not have access to this controller
  #
  def deny_if_user_exists
    if User.find_by_ldap_uid(ldap_user.uid)
      Rails.logger.debug("Existing user attempting to access new user form, redirecting")
      redirect_to(off_site_requests_url) and return
    else
      Rails.logger.debug("Non Existing user attempting to access new user form.")
      true
    end
  end

end
