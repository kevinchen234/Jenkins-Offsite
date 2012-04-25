class UcbRailsSecurityGenerator < Rails::Generator::Base
  NAMESPACE = 'ucb_security'
  TARGET_NAMESPACE = 'ucb_security'
  
  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|
      template_dir = File.join(File.expand_path(File.dirname(__FILE__)), "templates")
      
      ###############
      # Models
      #
      Dir["#{template_dir}/models/*"].each do |name|
        name = File.basename(name)
        m.file "models/#{name}", "app/models/#{name}"
      end
      #####
      
      
      ###############
      # Controllers
      #
      m.directory "app/controllers/#{TARGET_NAMESPACE}/"
      Dir["#{template_dir}/controllers/#{NAMESPACE}/*"].each do |name|
        name = File.basename(name)
        m.file "controllers/#{NAMESPACE}/#{name}", "app/controllers/#{TARGET_NAMESPACE}/#{name}"
      end
      
      # Helpers
      m.directory "app/helpers/#{TARGET_NAMESPACE}"
      Dir["#{template_dir}/helpers/#{NAMESPACE}/*"].each do |name|
        name = File.basename(name)
        m.file "helpers/#{NAMESPACE}/#{name}", "app/helpers/#{TARGET_NAMESPACE}/#{name}"
      end
      #####
      
      # Tasks
      m.directory "lib/tasks/"
      Dir["#{template_dir}/tasks/*"].each do |name|
        name = File.basename(name)
        m.file "tasks/#{name}", "lib/tasks/#{name}"
      end
      #####
      
      
      ################
      # Views
      #
      m.directory "app/views/#{TARGET_NAMESPACE}/"
      m.directory "app/views/#{TARGET_NAMESPACE}/roles/"
      Dir["#{template_dir}/views/#{NAMESPACE}/roles/*"].each do |name|
        name = File.basename(name)
        m.file "views/#{NAMESPACE}/roles/#{name}", "app/views/#{TARGET_NAMESPACE}/roles/#{name}"
      end
      
      m.directory "app/views/#{TARGET_NAMESPACE}/users/"
      Dir["#{template_dir}/views/#{NAMESPACE}/users/*"].each do |name|
        name = File.basename(name)
        m.file "views/#{NAMESPACE}/users/#{name}", "app/views/#{TARGET_NAMESPACE}/users/#{name}"
      end
      
      m.directory "app/views/#{TARGET_NAMESPACE}/user_roles/"
      Dir["#{template_dir}/views/#{NAMESPACE}/user_roles/*"].each do |name|
        name = File.basename(name)
        m.file "views/#{NAMESPACE}/user_roles/#{name}", "app/views/#{TARGET_NAMESPACE}/user_roles/#{name}"
      end
      
      m.directory "app/views/#{TARGET_NAMESPACE}/role_users/"
      Dir["#{template_dir}/views/#{NAMESPACE}/role_users/*"].each do |name|
        name = File.basename(name)
        m.file "views/#{NAMESPACE}/role_users/#{name}", "app/views/#{TARGET_NAMESPACE}/role_users/#{name}"
      end
      
      m.directory "app/views/#{TARGET_NAMESPACE}/role_users/"
      Dir["#{template_dir}/views/#{NAMESPACE}/role_users/*"].each do |name|
        name = File.basename(name)
        m.file "views/#{NAMESPACE}/role_users/#{name}", "app/views/#{TARGET_NAMESPACE}/role_users/#{name}"
      end
      
      m.directory "app/views/#{TARGET_NAMESPACE}/ldap_search/"
      Dir["#{template_dir}/views/#{NAMESPACE}/ldap_search/*"].each do |name|
        name = File.basename(name)
        m.file "views/#{NAMESPACE}/ldap_search/#{name}", "app/views/#{TARGET_NAMESPACE}/ldap_search/#{name}"
      end
      #####
      
      
      ###############
      # Layouts
      #
      m.directory "app/views/layouts/#{TARGET_NAMESPACE}"
      Dir["#{template_dir}/views/layouts/#{NAMESPACE}/*"].each do |name|
        name = File.basename(name)
        m.file "views/layouts/#{NAMESPACE}/#{name}", "app/views/layouts/#{TARGET_NAMESPACE}/#{name}"
      end
      #####
      
      
      ###############
      # Stylesheets
      #
      m.file "stylesheets/#{NAMESPACE}.css", "public/stylesheets/#{TARGET_NAMESPACE}.css"
      #####
      
      
      ###############
      # Javascripts
      #
      m.file "javascripts/ucb_security.js", "public/javascripts/ucb_security.js"
      #####
      

      ###############
      # Initializers
      #
      m.directory "config"
      m.directory "config/initializers"
      m.file "initializers/ucb_security_config.rb", "config/initializers/ucb_security_config.rb"
      #####

      
      ###############
      # Migrations
      #
      m.directory "db/migrate"
      m.file "db/migrate/xxx_create_ucb_rails_security_tables.rb", "db/migrate/#{next_migration}_create_ucb_rails_security_tables.rb"
      #####
      
      
      ###############
      # Routes
      #
      write_named_routes_to_route_file
      #####
    end
  end
  
  private
    def pad_zeros(str, num_of_zeros)
      if str.length == num_of_zeros
        return str
      else
        pad_zeros("0".concat(str), num_of_zeros)
      end
    end
    
    def latest_migration
      num = 0
      unless migrations.empty?
        migrations.last =~ /^([0-9]+)_/
        num = $1
      end
      raise(Exception, "Unable to determine latest migration: #{migrations.last}") unless num
      num.to_i
    end
    
    def next_migration
      Time.now.utc.strftime("%Y%m%d%H%M%S")      
      #pad_zeros((latest_migration + 1).to_s, 3)
    end
    
    def migrations
      Dir["#{Rails.root}/db/migrate/*"].map { |f| File.basename(f) }
    end
  
    def write_named_routes_to_route_file
      ucb_security_routes = <<-ROUTE
      map.ucb_security '/ucb_security', :controller => 'ucb_security/users'
      map.logout '/logout', :controller => 'ucb_security/base', :action => 'logout'
      map.not_authorized '/not_authorized', :controller => 'ucb_security/base', :action => 'not_authorized'

      map.namespace(:ucb_security) do |ucb_security|
        ucb_security.resources :roles do |roles|
          roles.resource :users, :controller => 'role_users'
        end

        ucb_security.resources :users do |users|
          users.resource :roles, :controller => 'user_roles'
        end
      end

      map.ucb_security_ldap_search '/ucb_security/ldap_search', 
        :controller => 'ucb_security/ldap_search', :action => 'index'
      ROUTE
      
      sentinel = 'ActionController::Routing::Routes.draw do |map|'
      gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
          "#{match}\n  # START ucb_rails_security routes: \n  #{ucb_security_routes}\n # END ucb_rails_security routes:\n"
      end   
    end
  
    def gsub_file(relative_destination, regexp, *args, &block)
      path = destination_path(relative_destination)
      content = File.read(path).gsub(regexp, *args, &block)
      File.open(path, 'wb') { |file| file.write(content) }
    end
end
