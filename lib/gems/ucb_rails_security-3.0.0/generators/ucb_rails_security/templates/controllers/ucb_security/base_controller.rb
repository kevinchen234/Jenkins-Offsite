class UcbSecurity::BaseController < ApplicationController
  # Move this include into your ApplicationController to add security to your entire application
  include UCB::Rails::Security::ControllerMethods
  
  layout 'layouts/ucb_security/application'
  # Only allow access to users that have the "Security" role
  before_filter :filter_role_security, :except => [:not_authorized, :logout]
  
  before_filter :append_headers

private
  def append_headers
    response.headers['Cache-Control'] = "no-store, no-cache, must-revalidate"
    response.headers['Expires'] = "The, 01 Jan 1970 00:00:00 GMT"
    response.headers['Pragma'] = "no-cache"    
  end
end
