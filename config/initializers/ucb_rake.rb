require 'yaml'

################################################################################
# war_deployer.rake 
################################################################################
#
# If you want to automate local war deployments to JBoss or Tomcat, edit the
# file: Rails.root/config/war_deployer.yml (it is reccommended that you add
# war_deployer.yml to svn:ignore)
#
# *war_deployer.yml*
#   tomcat_home: /path/to/tomcat/home
#   jboss_home: /path/to/jboss/home
#
#
war_config = Rails.root + "/config/war_deployer.yml"
if File.exists?(war_config)
  war_deployer = YAML.load_file(war_config)
  JBOSS_HOME = war_deployer["jboss_home"] if war_deployer.has_key?("jboss_home")
  TOMCAT_HOME = war_deployer["tomcat_home"] if war_deployer.has_key?("tomcat_home")
end

