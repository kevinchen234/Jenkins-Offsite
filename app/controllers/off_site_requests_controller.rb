class OffSiteRequestsController < ApplicationController
  #before_filter :filter_logged_in
  before_filter :ensure_authenticated_user
  before_filter :ensure_user_created
  before_filter :filter_in_user_table
  before_filter :major_tab_off_site_requests
  before_filter :load_os_req, :only => [:edit, :update, :destroy, :show]
  before_filter :build_department_list, :only => [:new, :edit, :update, :create]
  before_filter :build_status_list, :only => [:new, :edit, :update, :create]
  before_filter :build_campus_buyers_list, :only => [:new, :edit, :update, :create]
  before_filter :build_ext_circumstances_list, :only => [:new, :edit, :update, :create]

  skip_before_filter :verify_authenticity_token, :only => :index


  #### No Test spec yet ####

  def index
    @os_reqs = current_user.off_site_requests
  end

  def new
    @os_req = current_user.off_site_requests.build
  end

  def edit
  end

  def show
  end

  def create
    @os_req = current_user.off_site_requests.build(params[:off_site_request])
    @os_req.attributes = params[:off_site_request]
    @os_req.send_email_notification = true
    if @os_req.save
      flash[:notice] = msg_created(@os_req) + " Please check your email for further instructions."
      redirect_to(edit_off_site_request_url(@os_req))
    else
      render("new")
    end
  end

  def update
    @os_req.send_email_notification = true
    if @os_req.update_attributes(params[:off_site_request])
      flash[:notice] = msg_updated(@os_req) + " Please check your email for further instructions."
      redirect_to(edit_off_site_request_url(@os_req))
    else
      render("edit")
    end
  end

  def destroy
    @os_req.destroy
    flash[:notice] = msg_destroyed(@os_req)
    redirect_to(off_site_requests_url)
  end


  protected

  ##
  # User must be in the user table, otherwise they need to verify their user information.
  #
  def ensure_user_created
    if User.find_by_ldap_uid(ldap_user.uid)
      Rails.logger.debug("User in user table.")
      true
    else
      Rails.logger.debug("User not in user table, redirecting to new user form.")
      redirect_to(new_users_url) and return
    end
  end

  def load_os_req
    @os_req = current_user.off_site_requests.find(params[:id])
  end

  def build_department_list
    @department_list = UCB::LDAP::Org.build_department_list
    if ENV['RAILS_ENV'] == "test"
      @department_list << "test"
    end
  end

  def build_status_list
    @status_list = Status.all
  end

  def build_campus_buyers_list
    @campus_buyers_list = User.campus_buyers_select_list
  end

  def build_ext_circumstances_list
    @ext_circumstances_list = ExtCircumstance.select_list
  end

end

