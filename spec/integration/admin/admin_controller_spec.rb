require 'spec_helper'
include RspecIntegrationHelpers

describe "Admin::admin access control" do
  fixtures(:all)

  before(:all) do
    @admin =  User.find(ActiveRecord::Fixtures.identify(:runner))
    @user =  User.find(ActiveRecord::Fixtures.identify(:user))
  end
  
  it "should allow users with admin role access to admin area" do
    login_user(@admin)
    # successful auth redirects to admin_off_site_requests_url
    visit_path(admin_root_path)
    assert_have_selector("h1#banner", :content => "ADMIN")
    assert_contain("Listing Off-Site Requests")
    logout_current_user
  end
  
   it "should restrict access for users without admin role" do
     login_user(@user)
     # failed auth redirects to not_authorized_url
     visit(admin_root_path)
     assert_contain("Not Authorized")
     logout_current_user
   end
end
