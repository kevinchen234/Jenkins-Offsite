# this class is used to test the connectity of the database, 
# it has no relationship to application's domain 

class AppMonitorController < ApplicationController
  skip_before_filter(:filter_in_user_table)

  #### No tests yet ####

  def index
    AppMonitor.first
    render(:text => "Ok", :status => 200)
  end

  def test_exception
    raise Exception
  end
end
