require 'spec_helper'

include RspecIntegrationHelpers

describe "Admin User CRUD interface" do
  fixtures :all

  before(:all) do
    @admin = User.find(ActiveRecord::Fixtures.identify(:runner))
    login_user(@admin.ldap_uid)

    @runner = User.find(ActiveRecord::Fixtures.identify(:runner))
    @disabled = User.find(ActiveRecord::Fixtures.identify(:disabled))
  end

  it "should list all users and the number" do
    visit_path(admin_users_path)
    assert_contain("Listing Users")
    assert_contain("(8)")

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
    assert_contain("Listing Users (9)")
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
    assert_contain("(7)")
    assert_have_no_selector(row_sel(@disabled))
    assert_have_selector(".flash_notice", :content => "User successfully deleted.")
  end

  it "should be able to log in a user?"
end