$TESTING = true

$:.unshift(File.dirname(__FILE__) + '/../lib')
require "ucb_rails_security"

# Swallow logger calls during testing
module Mock
  class Logger
     def debug(msg); end
     def info(msg); end
  end
end
UCB::Rails::Security.logger = Mock::Logger.new

def reset_cas_authentication_class()
  ca = UCB::Rails::Security::CASAuthentication
  ca.reset_instance_variables()
  ca
end

# Mixin like a Rails application will
module ActionController
  class Base
    include UCB::Rails::Security::ControllerMethods
    attr_accessor :session  # mock -- this will be provided by Rails
  end
end

# Return new ActionController::Base
def new_controller
  c = ActionController::Base.new
  c.session = {}
  c
end

class User
end
