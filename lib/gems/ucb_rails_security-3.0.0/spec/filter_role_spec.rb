require "#{File.dirname(__FILE__)}/_setup.rb"

describe "Filter Role" do

  context "The Role filter" do
    before(:each) do
      @controller = new_controller()
      UCB::Rails::Security.using_user_table = true
    end

    specify "should call filter_logged_in when user not logged in" do
      @controller.should_receive(:filter_logged_in).and_return(false)
      @controller.filter_role_foo.should be_false
    end

    specify "should call filter_in_user_table() when user logged in" do
      @controller.stub!(:filter_logged_in).and_return(true)
      @controller.should_receive(:filter_in_user_table).and_return(false)
      @controller.stub!(:redirect_to)
      @controller.stub!(:not_authorized_url).and_return("nal")
      @controller.filter_role_foo.should be_false
    end
  end

end

describe "Role filters" do
  before(:each) do
    @controller = new_controller()
    @controller.stub!(:role_names).and_return(%w{role1 role2 role3})
    @controller.stub!(:filter_logged_in).and_return(true)
    @controller.stub!(:filter_in_user_table).and_return(true)
    @controller.stub!(:redirect_to)
    @controller.stub!(:not_authorized_url).and_return("nal")
  end

  it "filter_role_rolename should return true if one of user's roles is 'rolename'" do
    @controller.filter_role_role1.should be_true
  end

  it "filter_role_rolename should return false unless one of user's roles is 'rolename'" do
    @controller.filter_role_bogus.should_not be_true
  end

  it "filter_role_has_one_of_r1_or_r2_or_r3 returns true if user has one of the roles" do
    @controller.filter_role_has_one_of_role3_or_role4.should be_true
  end

  it "filter_role_has_one_of_r1_or_r2_or_r3 returns false unless user has one of the roles" do
    @controller.filter_role_has_one_of_role4_or_role5.should be_false
  end

  it "filter_role_has_all_of_r1_and_r2_and_r3 returns true if user has all of the roles" do
    @controller.filter_role_has_all_of_role1_and_role2.should be_true
  end

  it "filter_role_has_one_of_r1_and_r2_and_r3 returns false unless user has one of the roles" do
    @controller.filter_role_has_all_of_role3_and_role4.should be_false
  end
end