class Admin::AdminController < ApplicationController
  #before_filter :filter_role_admin
  
  layout 'admin'

  def index
    redirect_to admin_off_site_requests_url
  end
end
