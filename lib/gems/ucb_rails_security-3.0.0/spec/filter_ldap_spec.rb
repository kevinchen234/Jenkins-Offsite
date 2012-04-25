require "#{File.dirname(__FILE__)}/_setup.rb"

describe "Filter LDAP" do

  context "For an LDAP attribute" do

    before (:each) do
      @controller = new_controller()
    end

    specify "true is true" do
      @controller.ldap_boolean(true).should be_true
    end

    specify "a string is true" do
      @controller.ldap_boolean("x").should be_true
    end

    specify "a number, including 0, is true" do
      @controller.ldap_boolean(0).should be_true
    end

    specify "a populated Array is true" do
      @controller.ldap_boolean(["x"]).should be_true
    end

    specify "false is false" do
      @controller.ldap_boolean(false).should be_false
    end

    specify "nil is false" do
      @controller.ldap_boolean(nil).should be_false
    end

    specify "' ' is false" do
      @controller.ldap_boolean(' ').should be_false
    end

    specify "[] is false" do
      @controller.ldap_boolean([]).should be_false
    end
  end

  context "When a user is not logged in to the application" do

    before (:each) do
      @controller = new_controller()
      @controller.should_receive(:filter_logged_in)
    end

    specify "call to ldap_filter should call filter_logged_in" do
      @controller.filter_ldap_anthing
    end
  end

  context "When a user is logged in to the application" do

    before(:all) do
      ENV['RAILS_ENV'] = "re"
    end

    before (:each) do
      @ldap_uid = '42'
      @ldap_user = mock("ldap_user")
      UCB::LDAP::Person.stub!(:find_by_uid).and_return(@ldap_user)
      User.stub!(:find_by_ldap_uid)
      @controller = new_controller()
      @controller.application_login(@uid)
      @controller.stub!(:redirect_to)
      @controller.stub!(:not_authorized_url).and_return("nal")
    end

    specify "filter_ldap_method returns 'true' when ldap.method does" do
      @ldap_user.stub!(:attr_true).and_return(true)
      @controller.filter_ldap_attr_true.should be_true
    end

    specify "filter_ldap_method returns 'false' when ldap.method does" do
      @ldap_user.stub!(:attr_false).and_return(false)
      @controller.filter_ldap_attr_false.should be_false
    end

    specify "filter_ldap_method__eq__value is true if ldap.method eq 'value'" do
      @ldap_user.stub!(:attr).and_return("a")
      @controller.filter_ldap_attr__eq__a.should be_true
      @controller.filter_ldap_attr__eq__b.should be_false
    end

    specify "filter_ldap_method__ne__value is true if ldap.method ne 'value'" do
      @ldap_user.stub!(:attr).and_return("a")
      @controller.filter_ldap_attr__ne__b.should be_true
      @controller.filter_ldap_attr__ne__a.should be_false
    end

  end

end