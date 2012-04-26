require 'rubygems'
require 'rails'

begin
  require 'action_pack'
rescue
  require 'actionpack'
end

require 'action_controller'

require 'rubycas-client'
require 'casclient'
require 'casclient/frameworks/rails/filter'

require 'ucb_ldap'

require 'helpers/rspec_helpers'
require 'ucb_rails_security_casauthentication'
require 'ucb_rs_controller_methods'
require 'ucb_rails_security_logger'


module UCB #:nodoc:
  module Rails #:nodoc:
    # = UCB Rails Security
    module Security

      # Returns +true+ if application is using a user table 
      # which must be named +User+.
      def self.using_user_table?
        @using_user_table
      end

      # Set this to +true+ if your application is using a +User+ table.
      def self.using_user_table=(bool)
        @using_user_table = bool
      end

      # URL user is redirected to when authorization fails. 
      # Defaults to '/not_authorized'
      def self.not_authorized_url()
        @not_authorized_url || '/not_authorized'
      end

      # Setter for not_authorized_url()
      def self.not_authorized_url=(url)
        @not_authorized_url = url
      end

      # Reset instance variables for testing
      def self.reset_instance_variables() #:nodoc:
        self.using_user_table = nil
        self.not_authorized_url = nil
      end

      def self.logger
        @logger ||= UCB::Rails::Security::Logger.new("#{::Rails.root}/log/ucb_security_#{::Rails.env}.log")
      end

      def self.logger=(val)
        @logger = val
      end
    end
  end
end
