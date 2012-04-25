# Implementation of UCB::Rails::Security

module UCB #:nodoc:
  module Rails #:nodoc:
    module Security
      # = CAS Authentication Class
      #
      # This class is where you override the default CAS settings.
      class CASAuthentication
    
        ENV_DEVELOPMENT = 'development'
        ENV_DEV_INTEGRATION = 'dev_integration'
        ENV_TEST = 'test'
        ENV_PRODUCTION = 'production'
      
        CAS_BASE_URL_TEST = "https://auth-test.berkeley.edu/cas"    
        CAS_BASE_URL_PRODUCTION = "https://auth.berkeley.edu/cas"
      
        def self.logger()
          UCB::Rails::Security.logger
        end
        
        # Filter for CAS authentication.  To use filter, in controller:
        # 
        #   before_filter UCB::Rails::Security::CASAuthentication
        #
        # or use the controller method instead
        #
        #   before_filter :filter_logged_in
        #
        def self.filter(controller) #:nodoc:
          logger.debug("In UCB::Rails::Security::CASAuthentication.filter")
          if environment == ENV_TEST && force_login_filter_true_for
            controller.session[:cas_user] = force_login_filter_true_for
            return true
          end
          CASClient::Frameworks::Rails::Filter.configure(
            :cas_base_url => self.cas_base_url(),
            :logger => self.logger()
          )

          logger.debug("Before CASClient::Frameworks::Rails::Filter.filter(controller)")
          if CASClient::Frameworks::Rails::Filter.filter(controller)
            logger.debug("After CASClient::Frameworks::Rails::Filter.filter(controller)")
            return true
          else
            return false
          end
        end

        # Returns CAS base url to be used for CAS authentication.  Default
        # is based on Rails environment (Rails.env).
        def self.cas_base_url
          return @cas_base_url if @cas_base_url
          (environment == ENV_PRODUCTION) ? CAS_BASE_URL_PRODUCTION : CAS_BASE_URL_TEST
        end

        def self.allow_test_entries?
          @allow_test_entries ||= (environment != ENV_PRODUCTION)
        end

        def self.allow_test_entries=(bool)
          @allow_test_entries = bool
        end

        # Setter for cas_base_url
        def self.cas_base_url=(url)
          @cas_base_url = url
        end

        # Returns CAS logout url
        def self.logout_url
          "#{self.cas_base_url}/logout"
        end
        
        def self.home_url=(url)
          @home_url = url
        end
        
        def self.home_url
          @home_url || "ucb_security"
        end
        
        # This method exists so it can be stubbed to test cas_base_url()
        def self.environment #:nodoc:
          ENV['RAILS_ENV']
        end
        
        # LDAP Uid for which login is forced successful if in test
        # environemnt.
        def self.force_login_filter_true_for()
          @force_login_filter_true_for || false
        end
    
        # In test environment, every call to #filter() will simulate
        # successful authentication for _ldap_uid_ if this method
        # is called.
        def self.force_login_filter_true_for=(ldap_uid)
          @force_login_filter_true_for = ldap_uid
        end
        
        # Servername is pulled from request object.
        # def self.server_name(controller) #:nodoc:
        #   $TESTING ? "host_with_port" : controller.request.host_with_port
        # end
        
        # Used for testing
        def self.reset_instance_variables() #:nodoc:
          self.force_login_filter_true_for = nil
          self.cas_base_url = nil
          self.allow_test_entries = nil
          self.home_url = nil
        end
      end
    end
  end
end