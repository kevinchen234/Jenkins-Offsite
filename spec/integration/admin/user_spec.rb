require 'spec_helper'

include RspecIntegrationHelpers

describe "Admin User CRUD interface" do
  fixtures :all

  before(:all) do
    @runner = User.find(ActiveRecord::Fixtures.identify(:runner))
    login_user(@runner.ldap_uid)

    @disabled = User.find(ActiveRecord::Fixtures.identify(:disabled))
    @user = User.find(ActiveRecord::Fixtures.identify(:user))
  end

  after(:all) { logout_current_user }

  it "should list all users and the number" do
    visit_path(admin_users_path)
    assert_contain("Listing Users")
    assert_contain("(9)") #based off the number of users in the fixtures. Change if users in fixtures changed

    #check for a couple of users that should be there, and the buttons they should have
    assert_have_selector(row_sel(@runner), :content => "Edit")
    assert_have_selector(row_sel(@runner), :content => "Login")
    assert_have_selector(row_sel(@disabled), :content => "Edit")
    assert_have_selector(row_sel(@disabled), :content => "Login")

  end

  it "should be able to create a new user" do
    visit_path(admin_users_path)
    assert_have_selector("a", :content => "New User")
    click_link("New User")
    assert_contain("New User")
    assert_have_no_selector("a", :content => "Delete")
    assert_have_selector("a", :content => "Lookup in LDAP")

    #try and submit invalid form (should be filled out with current user info, so uid and email will be duplicate)
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    #change duplicate fields and submit again
    fill_in("user_email", :with => "thisisatest@example.com")
    fill_in("user_ldap_uid", :with => "123456789")
    click_button("Submit")
    assert_contain("Edit User")
    assert_have_selector(".flash_notice", :content => "User successfully created.")

    click_link("View All")
    assert_contain("Listing Users (10)")
  end

  it "should be able to edit a user" do
    visit_path(admin_users_path)
    click_link_within(row_sel(@disabled), "Edit")
    assert_contain("Edit User")
    assert_have_selector("a", :content => "Delete")
    assert_have_no_selector("a", :content => "Lookup in LDAP")

    #fill in empty uid and make sure it gives an error
    fill_in("user_ldap_uid", :with => "")
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    fill_in("user_ldap_uid", :with => 1000000)
    choose("user_enabled_true") #says enabled is null whenever false is chosen. Not sure if intended.
    click_button("Submit")
    assert_contain("Edit User")
    assert_have_selector(".flash_notice", :content => "User successfully updated.")
    assert_have_selector("#user_ldap_uid", :value => "1000000")
  end

  it "should be able to delete a user" do
    visit_path(admin_users_path)
    click_link_within(row_sel(@disabled), "Edit")
    assert_contain("Edit User")

    #delete this user
    click_link("Delete")
    automate { selenium.get_confirmation() }

    assert_contain("Listing Users")
    assert_contain("(8)")
    assert_have_no_selector(row_sel(@disabled))
    assert_have_selector(".flash_notice", :content => "User successfully deleted.")

    #Make sure we can't delete a user that has a dependency
    visit_path(admin_users_path)
    assert_contain("Listing Users")
    assert_have_selector(row_sel(@runner))
    click_link_within(row_sel(@runner), "Edit")
    click_link("Delete")
    automate { selenium.get_confirmation }
    assert_contain("Edit User")
    # User has not been deleted
    assert_have_selector(".flash_error")
    visit_path(admin_users_path)
    assert_have_selector(row_sel(@runner))
  end

  it "should be able to log in a user" do
    visit_path(admin_users_path)
    assert_have_selector("div", :content => "Logged in as: #{@runner.full_name}") #currently logged in as Steven
    click_link_within(row_sel(@user), "Login")
    assert_contain("Welcome!")
    assert_have_selector("div", :content => "Logged in as: #{@user.full_name}")

    #make sure the newly logged in user stays logged in when visiting other pages
    visit_path(off_site_requests_path)
    assert_have_selector("div", :content => "Logged in as: #{@user.full_name}")
  end


end