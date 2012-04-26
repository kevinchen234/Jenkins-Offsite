# Include hook code here
require 'ucb_rails_security'
require 'ucb_rails_security_casauthentication'
require 'ucb_rs_controller_methods'
require 'helpers/rspec_helpers'
require 'ucb_rails_security_logger'

UCB::Rails::Security.logger = UCB::Rails::Security::Logger.new(Rails.root + "/log/ucb_security_#{Rails.env}.log")
UCB::Rails::Security.logger.formatter = UCB::Rails::Security::Logger::Formatter.new