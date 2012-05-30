# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'ucb_rails_security'
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steven Hansen, Steven Downey"]
  s.date = %q{2012-04-24}
  s.description = %q{Simplifies CAS auth and ldap authz within your rails application}
  s.email = %q{runner@berkeley.edu}
  s.extra_rdoc_files = ["CHANGELOG", "README", "lib/helpers/rspec_helpers.rb", "lib/ucb_rails_security.rb", "lib/ucb_rails_security_casauthentication.rb", "lib/ucb_rails_security_logger.rb", "lib/ucb_rs_controller_methods.rb", "rdoc_includes/application_controller_rb.txt"]
  s.files = ["CHANGELOG", "Manifest", "README", "Rakefile", "TODO", "generators/ucb_rails_security/templates/controllers/ucb_security/base_controller.rb", "generators/ucb_rails_security/templates/controllers/ucb_security/ldap_search_controller.rb", "generators/ucb_rails_security/templates/controllers/ucb_security/role_users_controller.rb", "generators/ucb_rails_security/templates/controllers/ucb_security/roles_controller.rb", "generators/ucb_rails_security/templates/controllers/ucb_security/user_roles_controller.rb", "generators/ucb_rails_security/templates/controllers/ucb_security/users_controller.rb", "generators/ucb_rails_security/templates/db/migrate/xxx_create_ucb_rails_security_tables.rb", "generators/ucb_rails_security/templates/helpers/ucb_security/base_helper.rb", "generators/ucb_rails_security/templates/helpers/ucb_security/builder.rb", "generators/ucb_rails_security/templates/helpers/ucb_security/roles_helper.rb", "generators/ucb_rails_security/templates/helpers/ucb_security/users_helper.rb", "generators/ucb_rails_security/templates/initializers/ucb_security_config.rb", "generators/ucb_rails_security/templates/javascripts/ucb_security.js", "generators/ucb_rails_security/templates/models/ldap_search.rb", "generators/ucb_rails_security/templates/models/role.rb", "generators/ucb_rails_security/templates/models/user.rb", "generators/ucb_rails_security/templates/models/user_roles.rb", "generators/ucb_rails_security/templates/stylesheets/ucb_security.css", "generators/ucb_rails_security/templates/tasks/ucb_rails_security.rake", "generators/ucb_rails_security/templates/views/layouts/ucb_security/_main_navigation.html.erb", "generators/ucb_rails_security/templates/views/layouts/ucb_security/application.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/ldap_search/index.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/role_users/_new.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/role_users/edit.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/roles/_users.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/roles/edit.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/roles/index.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/roles/new.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/roles/show.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/user_roles/edit.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/users/edit.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/users/index.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/users/new.html.erb", "generators/ucb_rails_security/templates/views/ucb_security/users/show.html.erb", "generators/ucb_rails_security/ucb_rails_security_generator.rb", "generators/ucb_rails_security/ucb_rails_security_initializer_generator.rb", "generators/ucb_rails_security/ucb_rails_security_models_generator.rb", "init.rb", "lib/helpers/rspec_helpers.rb", "lib/ucb_rails_security.rb", "lib/ucb_rails_security_casauthentication.rb", "lib/ucb_rails_security_logger.rb", "lib/ucb_rs_controller_methods.rb", "rdoc_includes/application_controller_rb.txt", "rspec/_all_specs.rb", "rspec/_setup.rb", "rspec/filter_ldap_spec.rb", "rspec/filter_role_spec.rb", "rspec/filter_spec.rb", "rspec/filter_user_spec.rb", "rspec/logged_in_status_spec.rb", "rspec/ucb_rails_security_casauthentication_spec.rb", "rspec/ucb_rails_security_spec.rb", "ucb_rails_security.gemspec", "test/test_rails-2.0.x/test/test_helper.rb", "test/test_rails-2.1.x/test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = 'http://ucbrb.rubyforge.org/ucb_rails_security'
  s.rdoc_options = ["-o doc --inline-source -T hanna lib/*.rb"]
  s.require_paths = ["lib"]
  s.rubyforge_project = 'ucbrb'
  s.summary = "Simplifies CAS auth and ldap authz within your rails application"
  s.test_files = ["test/test_rails-2.0.x/test/test_helper.rb", "test/test_rails-2.1.x/test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency('rubycas-client', '>= 2.0.1')
      s.add_runtime_dependency('ucb_ldap', '>= 2.0.0.pre1')
      s.add_runtime_dependency('actionpack', '>= 3.0.0')
      s.add_runtime_dependency('rspec', '>= 1.1.5')
      s.add_development_dependency('echoe', '>= 0')
    else
      s.add_dependency('rubycas-client', '>= 2.0.1')
      s.add_dependency('ucb_ldap', '>= 2.0.0')
      s.add_dependency('actionpack', '>= 3.0.0')
      s.add_dependency('rspec', '>= 1.1.5')
      s.add_dependency('echoe', '>= 0')
    end
  else
    s.add_dependency('rubycas-client', '>= 2.0.1')
    s.add_dependency('ucb_ldap', '>= 2 .0.0')
    s.add_dependency('actionpack', '>= 3.0.0')
    s.add_dependency('rspec', '>= 1.1.5')
    s.add_dependency('echoe', '>= 0')
  end
end
