class UcbRailsSecurityGenerator < Rails::Generator::Base
  NAMESPACE = 'ucb_security_models'
  
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
    end
  end
 
end