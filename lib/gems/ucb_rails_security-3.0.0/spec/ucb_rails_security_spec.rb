require "#{File.dirname(__FILE__)}/_setup.rb"

describe UCB::Rails::Security do
  before(:each) do
    @urs = UCB::Rails::Security
    @urs.reset_instance_variables()
  end

  it "should load the ruby-cas gem" do
    lambda { CAS::Filter }.should_not raise_error
  end
  
  it "should load the ucb-ldap gem" do
    lambda { UCB::LDAP }.should_not raise_error
  end

  it "should default to not using user table" do
    @urs.should_not be_using_user_table
  end
  
  it "should allow application to use user table" do
    @urs.using_user_table = true
    @urs.should be_using_user_table
  end
  
  it "should default not_authorized_url() to '/not_authorized'" do
    @urs.not_authorized_url.should == '/not_authorized'
  end
  
  it "should allow application to set its own 'not_authorized_url'" do
    @urs.not_authorized_url = 'my_nau'
    @urs.not_authorized_url.should == 'my_nau'
  end
end