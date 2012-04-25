
# Uncomment this if your Application uses a user table
#
# UCB::Rails::Security::using_user_table = true


# Change the log level:
# UCB::Rails::Security.logger.level = Logger::DEBUG
UCB::Rails::Security.logger.level = Logger::INFO


# When a user logs off CAS, the CAS logout page will display a link for 
# the user to return to the original application.  By default, UCB::Rails::Security
# uses http://appdomain.com/ucb_security
# Uncommening the below config would change it to: http://appdomain.com
#
# UCB::Rails::Security::CASAuthentication.home_url = ''


# By default, UCB::Rails::Security will return ldap test entries for all
# Rails environments except production.  Uncommenting the below will change
# the behaviour to return test ids for all environments.  You can also add
# this config option to a specific environment file to confine the config.
#
# UCB::Rails::Security::CASAuthentication.allow_test_entries = true