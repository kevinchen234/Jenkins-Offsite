class UcbRailsSecurityInitializerGenerator < Rails::Generator::Base
  NAMESPACE = 'ucb_security_initializer'
  
  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    record do |m|
      m.directory "config"
      m.directory "config/initializers"
      m.file "initializers/ucb_security_config.rb", "config/initializers/ucb_security_config.rb"
    end
  end
end