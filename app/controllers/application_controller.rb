# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  #include UCB::Rails::Security::ControllerMethods
  #include ExceptionNotification::Notifiable    #ExceptionNotification is not being found for some reason
  #include ExceptionNotification::ConsiderLocal

  before_filter :append_headers
  before_filter :auth_user_for_integration_tests

  #before_filter :ensure_authenticated_user
  helper :all
  protect_from_forgery

  skip_before_filter :verify_authenticity_token, :only => [:login, :logout]

  #### No tests yet ####

  def ensure_authenticated_user()
    if session[:ldap_uid].nil?
      session[:original_url] = request.env['REQUEST_URI']
      redirect_to(login_url)
    elsif ldap_user.nil?
      application_login
    end
  end


  def not_authorized
    render :text => "Not Authorized", :status => 401
  end

  ##
  # Enables us to programatically logout users without going to CAS during integration tests.
  #
  def logout
    if ["test", "app_scan"].include?(ENV["RAILS_ENV"])
      application_logout if params[:test_auth_ldap_uid]
      redirect_to root_url
    else
      super
    end
  end


  protected

  def local_request?
    false
  end

  #Missing in ExceptionNotification
  #exception_data :additional_data

  def additional_data
    current_user ? {:current_user => current_user } : {}
  end

  def append_headers
    response.headers['Cache-Control'] = "no-store, no-cache, must-revalidate"
    response.headers['Expires'] = "The, 01 Jan 1970 00:00:00 GMT"
    response.headers['Pragma'] = "no-cache"
  end

  ##
  # Enables us to programatically authenticate users without going to CAS during integration tests.
  #
  def auth_user_for_integration_tests()
    if ["test", "app_scan"].include?(ENV["RAILS_ENV"])
      if params[:test_auth_ldap_uid] && session[:ldap_uid].nil?
        application_login(params[:test_auth_ldap_uid])
      end
    end
  end

  def method_missing(method, *args)
    if method.to_s =~ /^msg_(.+)$/
      CrudMessage.send("msg_#{$1}", *args)
    elsif method.to_s =~ /^(.+)_tab_(.+)$/
      Rails.logger.debug("Setting Tab: #{$1} #{$2}")
      set_tab($1, $2)
    else
      super
    end
  end

  ##
  # Allows for setting of tab in before filters:
  #
  #   before_filter :major_tab_foo
  #   before_filter :minor_tab_bar
  #
  # Same as (in action):
  #
  #   major_tab :foo
  #   minor_tab :bar
  #
  def set_tab(tab_type, tab_name)
    tab = "#{tab_type}_tab_#{tab_name}"
    @major_tab = tab
  end

  protected

  # Logs ldap_uid into application.
  #
  # * get LDAP entry (available via ActionController::Base#ldap_user)
  # * check for user in User table (if using_user_table?)
  # * update User table columns with LDAP values
  #
  # This happens upon successful CAS authentication.  You can login
  # a particular user to your application by calling this method
  # with the corresponding ldap_uid.
  def application_login(ldap_uid=session[:ldap_uid]) #:doc:
    #_logger.debug("In application_login")
    #UCB::LDAP::Person.include_test_entries = UCB::Rails::Security::CASAuthentication.allow_test_entries?
    #_logger.debug("\tLDAP test entries will #{UCB::LDAP::Person.include_test_entries? || "NOT"} be included")
    #_logger.debug("Looking for authenticated user in LDAP: #{ldap_uid}")
    self.ldap_user = UCB::LDAP::Person.find_by_uid(ldap_uid)
    if ldap_user().nil?
      #_logger.debug("Unable to find user in LDAP.")
      #redirect_to(not_authorized_url())
      return false
    end
    #_logger.debug("Found user in LDAP.")
    look_for_user_in_user_table(ldap_uid)
  end

  def logout_cas
    application_logout
    protocol = request.ssl? ? 'https://' : 'http://'
    #url = UCB::Rails::Security::CASAuthentication.home_url
    #logout_url = UCB::Rails::Security::CASAuthentication.logout_url
    #redirect_to("#{logout_url}?url=#{protocol}#{request.host_with_port}/#{url}")
    redirect_to("localhost:3000")
  end
  def application_logout()
    [:cas_user, :ldap_user, :user_table_id, :casfilterpgt,
     :casfilterreceipt, :caslastticket, :casfiltergateway].each { |k| session[k] = nil }
  end



  def ensure_admin_user()
    unless user_is_admin?
      render(:text => "Not Authorized", :status => 404)
    end
  end

  def ldap_user=(ldap_user)
    session[:ldap_user] = ldap_user
  end

  def ldap_user()
    session[:ldap_user]
  end

  def current_user()
    if !ldap_user.nil?
      User.find_by_uid(ldap_user.uid)
    end
  end

  # Update User table entry with values from UCB::LDAP::Person instance.
  # This happens automatically when a user logs in and is found in
  # the User table.
  #
  # Applications can call this to update user table entries with
  # (presumably more current) LDAP information.  Each column name that
  # has a corresponding LDAP attribute or alias will be updated.
  def update_user_table(ldap_user, ar_user) #:doc:
    #_logger.debug("Updating users attributes to match LDAP.")
    User.content_columns.each do |col|
      begin
        ar_user.send("#{col.name}=", ldap_user.send(col.name.to_sym))
      rescue NoMethodError
        # It's okay.  Don't have LDAP attribute for given column.
      end
    end
    ar_user.save
  end

  # Check if user is in user table.  If found, update columns
  # with LDAP attributes of same name.
  def look_for_user_in_user_table(ldap_uid)
    #_logger.debug("Looking for user in user table.")
    ar_user = User.find_by_uid(ldap_uid)
    if ar_user
      #_logger.debug("Found user.")
      self.user_table_id = ar_user.id
      update_user_table(ldap_user, ar_user)
      return true
    else
      #_logger.debug("User NOT found.")
    end
  end

  # Returns the User table instance for the logged in user.
  def user_table_user() #:doc:
    user_table_id && (@user_table_user ||= User.find(user_table_id))
  end

  # Returns +true+ if user is logged in.  Does <b>not</b>
  # attempt to authenticate.
  def logged_in?() #:doc:
    ldap_user ? true : false
  end

  # Returns +true+ if user is logged in and was found in User table.
  # At authentication time.  Does <b>not</b> attempt to find user.
  def in_user_table?() #:doc:
    user_table_id ? true : false
  end

  # Returns +id+ column from User table for logged in user.
  def user_table_id() #:doc:
    session[:user_table_id]
  end

  # Setter for user_table_id.
  def user_table_id=(user_table_id)
    session[:user_table_id] = user_table_id
  end

  # Returns +true+ if user in user table.  If not logged in, user
  # is redirected to CAS authentication.
  def filter_in_user_table() #:doc:
    filter_logged_in or return false
    user_table_id ? true : false
  end

  # CAS authentication before_filter.  Use this filter to ensure
  # users have logged in, i.e. authenticated with CAS.
  def filter_logged_in() #:doc:
    #_logger.debug("In filter_logged_in")
    if logged_in?
      #_logger.debug("\tlogged_in? returned true")
      return true
    elsif !UCB::Rails::Security::CASAuthentication.filter(self)
      #_logger.debug("\tUCB::Rails::Security::CASAuthentication.filter returned false")
      return false
    end
    application_login
    true
  end

  # Returns +Array+ of user's role names, lowercased.  Returns
  # +nil+ if user is not in user table (or not logged in).
  def role_names() #:doc:
    roles && roles.map { |r| r.name.downcase }
  end

  # Returns +Array+ of +Role+ for logged in user.
  def roles() #:doc:
    user_table_user && user_table_user.roles
  end


  helper_method :ldap_user
  #helper_method :current_user
  helper_method :in_user_table?
  helper_method :logged_in?
  helper_method :user_table_id
  helper_method :role_names
  helper_method :roles
  helper_method :user_table_user
  helper_method :filter_in_user_table
  helper_method :filter_logged_in

end
