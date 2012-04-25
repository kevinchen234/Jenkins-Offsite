source 'https://rubygems.org'

gem 'rails', '3.2.3'  # Ruby On Rails application framework.
gem 'pg'  # Ruby client library for PostgreSQL relational database.

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'  # Sass adapter for the Rails asset pipeline.
  gem 'coffee-rails', '~> 3.2.1'  # CoffeScript adapter for the Rails asset pipeline.
  gem 'uglifier', '>= 1.0.3'  # Ruby wrapper for UglifyJS JavaScript compressor.
end

gem 'jquery-rails'  # Provides jQuery and the jQuery-ujs driver for Rails 3.
gem 'jquery-tmpl-rails'  # jQuery Templates for the Rails asset pipeline.

gem 'i18n'

gem 'formtastic', '= 0.9.7', :require => 'action_pack'  # Rails form builder with semantic accessible markup.
gem 'rubycas-client'  # Offsite v2 was '= 2.0.1'; current is 2.3.8.  # Client library for Central Authentication Service protocol.

#TODO experimental - the mainline ucb_ldap gem is v 1.4.2 which depends on ruby-net-ldap 0.0.4 which is five years old,
# and during our initial testing it seems to have problems connecting; Steven and Igor advise it may be that the gem
# is not compatible with Ruby 1.9x and also may not be threadsafe. So we're trying a local version of the gem,
# changing the dependency to net-ldap which is current, and putting the gem code in ./vendor/gems/ucb_ldap* for now.
gem 'ucb_ldap', '~> 2.0.0', :path => File.dirname(__FILE__)  + "/lib/gems/ucb_ldap-2.0.0"  # Convenience classes for interacing with UCB's LDAP directory.

#TODO deprecated - Steven advises we get rid of this; it's an older gem that provided Devise-like security.
# He recommends we upgrade the security to use OmniAuth and its plugins e.g. CAS; we can then remove ucb_rails_security.
gem 'ucb_rails_security', '~> 3.0.0', :path => File.dirname(__FILE__) + "/lib/gems/ucb_rails_security-3.0.0"  # Simplifies CAS auth and ldap authz within your rails application.

group :development, :test do
  gem 'rspec'  # Behavior Driven Development (BDD) for Ruby
  gem 'rspec-core'  #  RSpec runner and example groups.
  gem 'rspec-expectations'  # RSpec matchers for should and should_not.
  gem 'rspec-mocks'  # RSpec test double framework with stubbing and mocking.
  gem 'rspec-rails'  # RSpec version 2.x for Rails version 3.x
end
group :debugging do
  #gem 'ruby-debug19', :require => 'ruby-debug'  # Command line interface for ruby-debug.
end