require 'spec_helper'

include RspecIntegrationHelpers

describe "Navigation Bar" do
  fixtures :all

  after(:each) { logout_current_user }

  context "as an admin" do
    before(:each) do
      @admin = User.find(ActiveRecord::Fixtures.identify(:runner))
      login_user(@admin.ldap_uid)
    end
    it "should have 3 tabs" do
      visit_path(root_path)
      assert_have_selector("a", :content => "Site Home")
      assert_have_selector("a", :content => "Off-Site Requests")
      assert_have_selector("a", :content => "Admin")
    end

    it "should be able to visit admin site and see 6 tabs" do
      visit_path(admin_root_path)
      assert_have_selector("a", :content => "Site Home")
      assert_have_selector("a", :content => "Off-Site Requests")
      assert_have_selector("a", :content => "Users")
      assert_have_selector("a", :content => "Roles")
      assert_have_selector("a", :content => "Ext. Circumstances")
      assert_have_selector("a", :content => "Status")
    end
  end

  context "as a regular user" do
    before(:each) do
      @user = User.find(ActiveRecord::Fixtures.identify(:user))
      login_user(@user.ldap_uid)
    end

    it "should have 2 tabs" do
      visit_path(root_path)
      assert_have_selector("a", :content => "Site Home")
      assert_have_selector("a", :content => "Off-Site Requests")
    end

    it "should not be able to visit admin site" do
      visit_path(admin_root_path)
      assert_contain("Not Authorized")
    end
  end
end