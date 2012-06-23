# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'webrat'
require 'webrat/core/matchers'

#require 'capybara/rspec'
include Webrat::Methods
include Webrat::Matchers

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = true
  # Selenium mode
  #   config.mode = :selenium
  #   config.application_environment = :test
  #   config.application_address = "localhost"
  #   config.application_port = "3001"
end


RSpec::Matchers.define :be_valid do
  match do |actual|
    actual.valid?
  end

  failure_message_for_should do |actual|
    "expected that #{actual} would be valid (errors: #{actual.errors.full_messages.join("; ")})"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual} would not be valid"
  end

  description do
    "be valid"
  end

  #EMPLOYEE_LDAP_UID = "212386"

##
# Takes an object that responds to :ldap_uid
# Or, takes the ldap_uid as a String or Integer.
#
  def login_user(ldap_obj)
    if ldap_obj.is_a?(String) || ldap_obj.is_a?(Integer)
      ldap_uid = ldap_obj
    else
      ldap_uid = ldap_obj.ldap_uid
    end

    OmniAuth.config.test_mode = true
    OmniAuth.config.add_mock(:cas, { uid: ldap_uid.to_s })

    visit(login_url())
  end

end