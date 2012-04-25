require "#{File.dirname(__FILE__)}/_setup.rb"

describe UCB::Rails::Security::CASAuthentication do

  before(:all) do
    ENV['RAILS_ENV'] = "re"
  end
  
  before(:each) do
    @ca = reset_cas_authentication_class()
  end
  
  it "should set test CAS base url constant" do
    @ca::CAS_BASE_URL_TEST.should be_instance_of(String)
  end
  
  it "should set production CAS base url constant" do
    @ca::CAS_BASE_URL_PRODUCTION.should be_instance_of(String)
  end

  it "should default environment to Rails.env" do
    @ca.environment.should == ENV['RAILS_ENV']
  end
  
  it "should use the CAS production url for production" do
    @ca.stub!(:environment).and_return("production")
    @ca.cas_base_url.should == @ca::CAS_BASE_URL_PRODUCTION
  end
  
  it "should use the CAS test url for every thing else" do
    %w{development test qa bogus}.each do |environment|
      @ca.stub!(:environment).and_return(environment)
      @ca.cas_base_url.should == @ca::CAS_BASE_URL_TEST
    end
  end
  
  it "should allow application to set CAS url" do
    @ca.cas_base_url = "x"
    @ca.cas_base_url.should == "x"
  end
  
  it "should default not allowing test entries for production environment" do
    @ca.stub!(:environment).and_return(@ca::ENV_PRODUCTION)
    @ca.allow_test_entries?.should be_false
  end
  
  it "should default to allowing test entries for any environment other than production" do
    %w{development crap quality_assurance}.each do |env| 
      @ca.stub!(:environment).and_return(env)
      @ca.allow_test_entries?.should be_true
    end
  end
  
  it "should allow allow_test_entries to be set" do
    @ca.allow_test_entries = true
    @ca.stub!(:environment).and_return(@ca::ENV_PRODUCTION)
    @ca.allow_test_entries?.should be_true
  end
end

describe "UCB::Rails::Security::CASAuthentication filter" do
  before(:each) do
    @ca = reset_cas_authentication_class()
  end

  it "should succeed when CAS returns true" do
    CASClient::Frameworks::Rails::Filter.stub!(:filter).and_return(true)
    @ca.filter(new_controller()).should be_true
  end
  
  it "should fail when CAS returns false" do
    CASClient::Frameworks::Rails::Filter.stub!(:filter).and_return(false)
    @ca.filter(new_controller()).should be_false
  end
  
  it "should return true and set ldap_uid on demand in test environment" do
    @controller = new_controller()
    CASClient::Frameworks::Rails::Filter.stub!(:filter).and_return(false)
    @ca.stub!(:environment).and_return(@ca::ENV_TEST)
    @ca.force_login_filter_true_for = '123'
    @ca.filter(@controller).should == true
    @controller.ldap_uid.should == '123'
  end
end  
