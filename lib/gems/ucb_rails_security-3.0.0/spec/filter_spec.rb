require "#{File.dirname(__FILE__)}/_setup.rb"

describe "Controller method_missing() code" do
  before(:each) do
    @controller = new_controller()
  end
  
  it "should raise error if called with non-filter method" do
    lambda{@controller.bogus}.should raise_error(NoMethodError)
  end
  
  it "should always call filter_logged_in before other filters" do
    @controller.stub!(:filter_logged_in).and_return(false)
    @controller.filter_ldap_anything.should be_false
  end
  
  def ldap_setup(return_value)
    @ldap_user = mock("ldap_user")
    @ldap_user.stub!(:anything)
    @controller.stub!(:ldap_user).and_return(@ldap_user)
    @controller.stub!(:filter_logged_in).and_return(true)
    @controller.stub!(:ldap_boolean).and_return(return_value)    
  end
  
  it "should return true when filter returns true" do
    ldap_setup(true)
    @controller.filter_ldap_anything.should be_true    
  end
  
  it "should return false when filter returns false" do
    ldap_setup(false)
    @controller.stub!(:redirect_to)
    @controller.stub!(:not_authorized_url)
    @controller.filter_ldap_anything.should be_false
  end
  
end