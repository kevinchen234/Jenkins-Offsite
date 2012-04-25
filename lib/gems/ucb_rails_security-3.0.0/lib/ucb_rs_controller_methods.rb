module UCB #:nodoc:
  module Rails #:nodoc:
    module Security
      # == Overview
      # These methods are added to ActionController::Base
      # so they are available to all of your application's controllers.
      # 
      # Most of the time you will be using the various <tt>filter_*</tt> 
      # methods.  Note that most of these methods are implemented via method_missing
      # and are not explicitly listed in the "methods" section of this document.
      # For details see examples below as well as method_missing, filter_ldap and
      # filter_db_role.
      # 
      # There are several methods used primarily by the filter methods, but you
      # may find use for these in your controllers.  Many of these methods
      # are marked as "helper methods" and are available for use in your
      # views (*.rhtml templates) and helpers.  See ApplicationHelper for
      # more information.
      #
      # == How Does This Work?
      # Take a look at the following controller: +Rails.root/app/controllers/ucb_security/base_controller.rb+
      #
      # You should see the following:
      #
      #  class UcbSecurity::BaseController < ApplicationController
      #    # Move this include into your ApplicationController to add security to your entire application
      #    include UCB::Rails::Security::ControllerMethods
      #
      #    layout 'layouts/ucb_security/application'
      #    before_filter :filter_role_security, :except => [:not_authorized, :logout]
      #  end
      #
      # The +include+ line adds several methods to this base controller, many 
      # of which are filters.  The line <tt>before_filter :filter_role_security, :except => [:not_authorized, :logout]</tt> 
      # tells this controller to only allow a user with the 
      # security role access to the actions in this controller. Since all 
      # of the ucb_security controllers extend this base controller, that has 
      # the requires the user to have the security role for all actions
      # in the ucb_security module (with the exception of not_authorized and 
      # logout)
      #
      # When you add one of these filters to your controller, behind the scenes 
      # CAS authentication is handled for you: if the user has not yet authenticated 
      # they will be directed to CAS otherwise your filter will be run.
      # 
      # You may want to add this filter to your application controller.  If your 
      # entire site requires authentication then that is definitely the way to go.  
      # If only a handful of controllers require auth, then only add these filter 
      # methods to those specific controllers.
      #
      #   
      # ==Explicit Filters
      # 
      # User must be logged in:
      # 
      #   class MyController < ActionController::Base
      #     before_filter :filter_logged_in
      #   end
      #   
      # User must be in user table (assumes your application has
      # a +User+ table -- see UCB::Rails::Security):
      # 
      #   class MyController < ActionController::Base
      #     before_filter :filter_in_user_table
      #   end
      # 
      # ==LDAP Filters
      # 
      # Any LDAP attribute can be used in a dynamic LDAP filter.  More accurately, any method
      # that an instance of UCB::LDAP::Person responds to can be used in a filter.
      # 
      # To satisfy the filter, the method must return a broader-than-normal
      # definition of <tt>true</tt>: strings containing only spaces and empty arrays
      # are considered <tt>false</tt>.
      #  
      # Since UCB::LDAP::Person has <tt>employee?</tt> and <tt>student?</tt> methods,
      # we can do the following:
      #
      #   class MyController < ActionController::Base
      #     before_filter :filter_ldap_employee?
      #     before_filter :filter_ldap_student?
      #   end
      # 
      # You can use any valid UCB::LDAP::Person method or LDAP attribute as the
      # "method" part of :filter_ldap_method.  Just keep in mind what constitutes
      # "true".
      # 
      # Since there is no "bogus" attribute, the following raises a <tt>NoMethodError</tt>
      # exception:
      # 
      #   class MyController < ActionController::Base
      #     before_filter :filter_ldap_bogus
      #   end
      #
      # You can filter based on the value of a particular attribute.
      # Currently supported operators are "eq" and "ne":
      #
      #   class MyController < ActionController::Base
      #     before_filter :filter_ldap_deptid__eq__JKASD
      #     before_filter :filter_ldap_lastname__ne__Badenov
      #   end
      # 
      # === Note
      # 
      # LDAP filters call the filter_logged_in filter.
      # 
      # == User Filters
      #
      # <b>NOTE</b>: Make sure you have <tt># UCB::Rails::Security::using_user_table = true</tt>
      # in your <tt>Rails.root/config/initializers/ucb_security_config.rb</tt> file, before trying
      # to use these filters.
      #
      # If your application has a user table you can do controller filtering
      # based on your user table:
      # 
      # The following only allows people who can update to access the controller:
      # 
      #   class User < ActiveRecord::Base
      #     def can_update?
      #       <complicated logic>
      #     end
      #   end
      # 
      #   class UpdateController < ActionController::Base
      #      before_filter :filter_user_can_update?
      #   end
      #
      # Filters of the form <tt>:filter_user_method</tt> are passed/failed
      # based on the return value of <tt>User#method</tt>. 
      #
      # === Non-boolean User Filters
      #
      # You can filter based on the value of a particular +User+ table
      # method.  Currently supported operators are "eq" and "ne":
      #
      #   class DoeNotJohnController < ActionController::Base
      #      before_filter :filter_user_lastname__eq__Doe
      #      before_filter :filter_user_firstname__ne__John
      #   end
      #
      # === Note
      # 
      # All User filters call the filter_logged_in and filter_in_user_table filters.
      #
      # ==Role Filters
      # 
      # If your application has both a user and
      # a roles table (see UCB::Rails::Security) 
      # you can use dynamic database role filters.  
      # 
      # Your user class must repond to the "roles" message
      # by returning an Array of objects that respond to the "name"
      # message.
      #
      # The following verifies the user has the "admin" role:
      # 
      #   class MyController < ActionController::Base
      #     before_filter :filter_role_admin
      #   end
      #
      # In general, the ":filter_role_rolename" filter verifies that the
      # user holds the "rolename" role.
      # 
      # The following verifies the user has the "admin" <b>and</b> "super_user" roles:
      # 
      #   class MyController < ActionController::Base
      #     before_filter :filter_role_has_all_of_admin_and_super_user
      #   end
      #
      # The following verifies the user has either the "guest" <b>or</b> "user" roles:
      # 
      #   class MyController < ActionController::Base
      #     before_filter :filter_role_has_one_of_guest_or_user
      #   end
      #
      # === Note
      # 
      # Role filters call the filter_logged_in and filter_in_user_table filters.
      #
      # == Helper Methods
      #
      # Several of the methods in this module are exposed as helper methods
      # that you can use in your views (<tt>../app/views/<controller>/*.rhtml</tt>)
      # and helpers (<tt>../app/helpers/<controller>_helper.rb</tt>).
      #
      #   # in your view
      #
      #   <% if logged_in? %>
      #   Logged in as: <%= "#{ldap_user.firstname} #{ldap_user.lastname}"%>
      #   <% end %>
      #
      # Or even better, used in a helper method you write:
      #
      #   # in your view
      #
      #   <%= logged_in_html %>
      #
      #   # in your controller's helper
      #
      #   def logged_in_html
      #     logged_in? ? "" : "Logged in as #{ldap_user.firstname} #{ldap_user.lastname}"
      #   end
      #
      # See the HELPER_METHODS constant below for a list of the methods.
      #
      module ControllerMethods

        # These methods are available has helpers in your views and helpers.
        HELPER_METHODS = [
            :in_user_table?,
            :ldap_user,
            :logged_in,
            :role_names,
            :roles,
            :ldap_uid,
            :user_table_user,
            :user_table_id,
            :using_user_table?,
            :logout,
        ]

        # Operators available for non-boolean LDAP and User filters.
        OPERATOR_METHODS = {
            "eq" => "==",
            "ne" => "!=",
        }

        def not_authorized
          render :text => "Not Authorized", :status => 401
        end

        # Logs user out of application
        def logout
          application_logout
          protocol = request.ssl? ? 'https://' : 'http://'
          url = UCB::Rails::Security::CASAuthentication.home_url
          logout_url = UCB::Rails::Security::CASAuthentication.logout_url
          redirect_to("#{logout_url}?url=#{protocol}#{request.host_with_port}/#{url}")
        end

        private unless $TESTING

        def application_logout()
          [:cas_user, :ldap_user, :user_table_id, :casfilterpgt,
           :casfilterreceipt, :caslastticket, :casfiltergateway].each { |k| session[k] = nil }
        end

        # CAS authentication before_filter.  Use this filter to ensure
        # users have logged in, i.e. authenticated with CAS.
        def filter_logged_in() #:doc:
          _logger.debug("In filter_logged_in")
          if logged_in?
            _logger.debug("\tlogged_in? returned true")
            return true
          elsif !UCB::Rails::Security::CASAuthentication.filter(self)
            _logger.debug("\tUCB::Rails::Security::CASAuthentication.filter returned false")
            return false
          end
          application_login
          true
        end

        # Logs ldap_uid into application.  
        # 
        # * get LDAP entry (available via ActionController::Base#ldap_user)
        # * check for user in User table (if using_user_table?)
        # * update User table columns with LDAP values 
        # 
        # This happens upon successful CAS authentication.  You can login
        # a particular user to your application by calling this method
        # with the corresponding ldap_uid.
        def application_login(ldap_uid=ldap_uid) #:doc:
          _logger.debug("In application_login")
          UCB::LDAP::Person.include_test_entries = UCB::Rails::Security::CASAuthentication.allow_test_entries?
          _logger.debug("\tLDAP test entries will #{UCB::LDAP::Person.include_test_entries? || "NOT"} be included")
          _logger.debug("Looking for authenticated user in LDAP: #{ldap_uid}")
          self.ldap_user = UCB::LDAP::Person.find_by_uid(ldap_uid)
          if ldap_user().nil?
            _logger.debug("Unable to find user in LDAP.")
            redirect_to(not_authorized_url())
            return false
          end
          _logger.debug("Found user in LDAP.")
          look_for_user_in_user_table(ldap_uid) if using_user_table?
        end

        # Check if user is in user table.  If found, update columns
        # with LDAP attributes of same name.
        def look_for_user_in_user_table(ldap_uid)
          _logger.debug("Looking for user in user table.")
          if ar_user = User.find_by_ldap_uid(ldap_uid)
            _logger.debug("Found user.")
            self.user_table_id = ar_user.id
            update_user_table(ldap_user, ar_user)
            return true
          else
            _logger.debug("User NOT found.")
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
          _logger.debug("Updating users attributes to match LDAP.")
          User.content_columns.each do |col|
            begin
              ar_user.send("#{col.name}=", ldap_user.send(col.name.to_sym))
            rescue NoMethodError
              # It's okay.  Don't have LDAP attribute for given column.
            end
          end
          ar_user.save
        end

        # Returns +true+ if using a User table.  
        # Gets value from UCB::Rails::Security::using_user_table?.
        def using_user_table?() #:doc:
          UCB::Rails::Security::using_user_table?
        end

        # Returns LDAP_UID of logged in user 
        def ldap_uid() #:doc:
          session[:cas_user]
        end

        # Returns UCB::LDAP::Person instance of logged in user.
        def ldap_user() #:doc:
          session[:ldap_user]
        end

        # Returns +id+ column from User table for logged in user.
        def user_table_id() #:doc:
          session[:user_table_id]
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

        # Setter for ldap_user.
        def ldap_user=(ldap_user)
          session[:ldap_user] = ldap_user
        end

        # Setter for user_table_id.
        def user_table_id=(user_table_id)
          session[:user_table_id] = user_table_id
        end

        # Setter for user_table_user.
        def user_table_user=(user_table_instance)
          @user_table_user = user_table_instance
        end

        # Dynamic filter implementation.
        def method_missing(method, *args)
          return super unless method.to_s =~ /^filter_(ldap|user|role)_(.+)$/
          filter_kind = $1
          filter_method = $2

          _logger.debug("#{method} dispatched to method_missing()")

          _logger.debug("before filter_logged_in")
          filter_logged_in or return false
          _logger.debug("after filter_logged_in")

          _logger.debug("Beginning Authorization")
          return true if case filter_kind
                           when "ldap"
                             filter_ldap(filter_method)
                           when "user"
                             filter_user(filter_method)
                           when "role"
                             filter_role(filter_method)
                         end

          redirect_to(not_authorized_url)
          _logger.debug("Authorization Failed")
          return false
        end

        # Processes LDAP filters.
        def filter_ldap(method)
          _logger.debug("In filter_ldap(): processing LDAP based authorization filters")
          (method =~ /(.+)__(.+)__(.+)/) ? filter_extended(ldap_user.send($1), $2, $3) : ldap_boolean(ldap_user.send(method))
        end

        # Implements a special definition of truth for the purposes of the ldap filters.
        def ldap_boolean(ldap_attribute_value)
          case ldap_attribute_value
            when NilClass, FalseClass
              return false
            when String
              return false if ldap_attribute_value.strip.empty?
            when Array
              return false if ldap_attribute_value.empty? || ldap_attribute_value.all? { |x| x.nil? or x.empty? }
          end
          true
        end

        # +eval+ a boolean expression
        def filter_extended(left, operator, right)
          return eval("'#{left}' #{OPERATOR_METHODS[operator]} '#{right}'")
        end

        # Returns +true+ if user in user table.  If not logged in, user
        # is redirected to CAS authentication.
        def filter_in_user_table() #:doc:
          filter_logged_in or return false
          user_table_id ? true : false
        end

        # Prcoess User-based filters
        def filter_user(method)
          _logger.debug("In filter_user(): processing user based authorization filters")
          unless UCB::Rails::Security.using_user_table?
            _logger.debug("User table not enabled.")
            raise(Exception, "You must enable the user table to use user based filters")
            return false
          end
          filter_in_user_table or return false
          return filter_extended(user_table_user.send($1), $2, $3) if method =~ /(.+)__(.+)__(.+)/
          user_table_user.send(method)
        end

        # Process Role-based filters
        def filter_role(method)
          _logger.debug("In filter_role(): processing role based authorization filters")
          unless UCB::Rails::Security.using_user_table?
            _logger.debug("User table not enabled.")
            raise(Exception, "You must enable the user table to use role based filters")
            return false
          end
          filter_in_user_table or return false
          return roles_has_one_of($1) if method =~ /^has_one_of_(.+)$/
          return roles_has_all_of($1) if method =~ /^has_all_of_(.+)$/
          role_names.include?(method.downcase)
        end

        # Returns +true+ if user has one of specified roles.
        # 
        # Called like:
        # 
        #   before_filter filter_role_has_one_of_role1_or_role2_or_role3
        #
        def roles_has_one_of(roles_string)
          (roles_array(roles_string) & role_names).size > 0
        end

        # Returns +true+ if user has all specified roles.
        # 
        # Called like:
        # 
        #   before_filter filter_role_has_all_of_role1_and_role2_and_role3
        #
        def roles_has_all_of(roles_string)
          (roles_array(roles_string) - role_names).size == 0
        end

        # Parse role string.
        def roles_array(roles_string)
          roles_string.downcase.split(/_and_|_or_/)
        end

        # Returns +Array+ of +Role+ for logged in user.
        def roles() #:doc:
          user_table_user && user_table_user.roles
        end

        # Returns +Array+ of user's role names, lowercased.  Returns
        # +nil+ if user is not in user table (or not logged in).
        def role_names() #:doc:
          roles && roles.map { |r| r.name.downcase }
        end

        # Returns url where user is redirected upon failed authorization.
        def not_authorized_url() #:doc:
          UCB::Rails::Security.not_authorized_url
        end

        # Add HELPER_METHODS to controller classes including this module.
        def self.included(base)
          base.send(:helper_method, HELPER_METHODS)
        end

        def _logger
          UCB::Rails::Security.logger
        end

      end
    end
  end
end
