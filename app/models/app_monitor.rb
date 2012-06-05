# this class is used to test the connectity of the database, 
# it has no relationship to application's domain
class AppMonitor < ActiveRecord::Base
  #set_table_name is deprecated
  #set_table_name 'app_heartbeats'
end
