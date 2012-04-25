require "#{File.dirname(__FILE__)}/_setup.rb"
require 'rails'

describe "ActiveRecord::User after application login" do

  before(:all) do
    ENV['RAILS_ENV'] = "re"
  end

  before(:each) do
    UCB::LDAP::Person.should_receive(:find_by_uid).and_return("ldap_user")
    @controller = new_controller()
  end

  it "should not be accessed if not using user table" do
    UCB::Rails::Security.using_user_table = false
    User.should_not_receive(:find_by_ldap_uid)
    @controller.application_login("1")
  end

  specify "should be accessed if using user table" do
    UCB::Rails::Security.using_user_table = true
    User.should_receive(:find_by_ldap_uid)
    @controller.application_login("1")
  end
end

# -----------------------------------------------
# UserNotLoggedIn Shared Behavior
# -----------------------------------------------

def user_not_logged_in_setup
  @ca = reset_cas_authentication_class()
  @controller = new_controller()
end


shared_examples_for "UserNotLoggedIn" do

  specify "user should not be logged in" do
    @controller.should_not be_logged_in
  end

  specify "ldap_uid should not be set" do
    @controller.ldap_uid.should be_nil
  end

  specify "ldap user should not be set" do
    @controller.ldap_user.should be_nil
  end

  specify "filter_logged_in should call CASAuthentication.filter" do
    UCB::Rails::Security::CASAuthentication.should_receive(:filter).and_return(false)
    @controller.filter_logged_in().should be_false
  end

  specify "filter_logged_in should call application_login if CAS auth returns true" do
    UCB::Rails::Security::CASAuthentication.should_receive(:filter).and_return(true)
    @controller.should_receive(:application_login)
    @controller.filter_logged_in().should be_true
  end
end

# -----------------------------------------------
# UserLoggedIn Shared Behavior
# -----------------------------------------------

def user_logged_in_setup()
  @ldap_uid = '42'
  @ldap_user = mock("ldap_user")
  @ldap_user.stub!(:ldap_uid).and_return(@ldap_uid)
  UCB::LDAP::Person.stub!(:find_by_uid).and_return(@ldap_user)
  @controller = new_controller()
  @controller.session[:cas_user] = @ldap_uid # CAS::Filter does this
  @controller.stub!(:update_user_table)
  @controller.application_login
end

shared_examples_for "UserLoggedIn" do

  specify "ldap_user() returns LDAP entry for user" do
    @controller.ldap_user.should be_equal(@ldap_user)
  end

  specify "attempt to authenticate should not redirect to CAS" do
    CAS::Filter.should_not_receive(:filter)
    @controller.filter_logged_in.should be_true
  end

  specify "user should be logged in" do
    @controller.should be_logged_in
  end

  specify "ldap_uid() returns the ldap_uid" do
    @controller.ldap_uid.should == @ldap_uid
  end

end

# -----------------------------------------------
# UserNotInTable Shared Behavior
# -----------------------------------------------

def user_not_in_table_setup
  UCB::Rails::Security.using_user_table = true
  User.stub!(:find_by_ldap_uid).and_return(nil)
end

shared_examples_for "UserNotInTable" do

  specify "should be using user table" do
    @controller.should be_using_user_table
  end

  specify "should not be in user table" do
    @controller.should_not be_in_user_table
  end

  specify "user id should not be set" do
    @controller.user_table_id.should be_nil
  end

  specify "user table user should not be set" do
    @controller.user_table_user.should be_nil
  end

end

# -----------------------------------------------
# UserInTable Shared Behavior
# -----------------------------------------------

def user_in_table_setup
  UCB::Rails::Security.using_user_table = true
  @user_table_id = 42
  @user = mock("user")
  @user.stub!(:id).and_return(@user_table_id)
  User.stub!(:find_by_ldap_uid).and_return(@user)
  User.stub!(:find).and_return(@user)
end

shared_examples_for "UserInTable" do

  specify "should be using user table" do
    @controller.should be_using_user_table
  end

  specify "user table user should be user set" do
    @controller.user_table_user.should be_equal(@user)
  end

  specify "should be in user table" do
    @controller.should be_in_user_table
  end

  specify "user id should be set" do
    @controller.user_table_id.should == @user_table_id
  end

end

describe "Permutations of logged in/out, in/out of user table, plus final test for after logout" do

# -----------------------------------------------
# Not logged in, not in user table
# -----------------------------------------------

  context "Not logged in, not in user table" do
    before(:each) do
      user_not_in_table_setup()
      user_not_logged_in_setup()
    end

    it_should_behave_like "UserNotLoggedIn"
    it_should_behave_like "UserNotInTable"
  end

# -----------------------------------------------
# Not logged in, in user table
# -----------------------------------------------

  context "Not logged in, in user table" do
    before(:each) do
      user_in_table_setup()
      user_not_logged_in_setup()
    end

    it_should_behave_like "UserNotLoggedIn"
    it_should_behave_like "UserNotInTable"
  end

# -----------------------------------------------
# Logged in, not in user table
# -----------------------------------------------

  context "Logged in user, not in user table" do
    before(:each) do
      user_not_in_table_setup()
      user_logged_in_setup()
    end

    it_should_behave_like "UserLoggedIn"
    it_should_behave_like "UserNotInTable"
  end

# -----------------------------------------------
# Logged in, in user table
# -----------------------------------------------

  context "Logged in user, in user table" do
    before(:each) do
      user_in_table_setup()
      user_logged_in_setup()
    end

    it_should_behave_like "UserLoggedIn"
    it_should_behave_like "UserInTable"
  end

# -----------------------------------------------
# After logout, looks like not logged in
# -----------------------------------------------

  context "Logged in user, in user table, after logout" do
    before(:each) do
      user_in_table_setup()
      user_logged_in_setup()
      @controller.application_logout()
    end

    it_should_behave_like "UserNotLoggedIn"
    it_should_behave_like "UserNotInTable"
  end

end
