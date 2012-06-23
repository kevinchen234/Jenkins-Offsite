class Admin::AdminController < ApplicationController
  before_filter :filter_role_admin
  
  layout 'admin'

  def index
    redirect_to admin_off_site_requests_url
  end

  protected

  def filter_role_admin
    if current_user.nil?
      redirect_to not_authorized_url
    elsif !current_user.roles.include? (Role.find_by_name("admin"))
      redirect_to not_authorized_url
    end
  end
end
