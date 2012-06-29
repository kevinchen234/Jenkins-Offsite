require 'spec_helper'

include RspecIntegrationHelpers

describe "Admin Role CRUD interface" do
  fixtures :all

  before(:all) do
    @admin = User.find(ActiveRecord::Fixtures.identify(:runner))
    login_user(@admin.ldap_uid)

    @admin_role = Role.find(ActiveRecord::Fixtures.identify(:admin_role))
    @deletable_role = Role.find(ActiveRecord::Fixtures.identify(:deletable_role))
  end

  after(:all) { logout_current_user }

  it "should list all roles and the number" do
    visit_path(admin_roles_path)
    assert_contain("Listing Roles")
    assert_contain("(3)")

    #check for a couple of roles that should be there, and the buttons they should have
    assert_have_selector(row_sel(@admin_role), :content => "Edit")
    assert_have_selector(row_sel(@admin_role), :content => "Delete")
    assert_have_selector(row_sel(@deletable_role), :content => "Edit")
    assert_have_selector(row_sel(@deletable_role), :content => "Delete")

  end

  it "should be able to create a new role" do
    visit_path(admin_roles_path)
    assert_have_selector("a", :content => "New Role")
    click_link("New Role")
    assert_contain("New Role")

    #try and submit invalid form (everything is empty)
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    #fill in fields and try again
    fill_in("role_name", :with => "test role name")
    fill_in("role_description", :with => "This is a description for a test role.")
    click_button("Submit")
    assert_contain("Listing Roles")
    assert_have_selector(".flash_notice", :content => "Role successfully created.")
    assert_contain("(4)")
  end

  it "should be able to edit a role" do
    visit_path(admin_roles_path)
    click_link_within(row_sel(@deletable_role), "Edit")
    assert_contain("Edit Role")

    #make description empty and make sure it gives an error
    fill_in("role_description", :with => "")
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    fill_in("role_description", :with => "This is a new description for deletable role")
    click_button("Submit")
    assert_contain("Listing Roles")
    assert_have_selector(".flash_notice", :content => "Role successfully updated.")
    assert_have_selector(row_sel(@deletable_role), :content => "This is a new description for deletable role")
  end

  it "should be able to delete a role" do
    visit_path(admin_roles_path)
    click_link_within(row_sel(@deletable_role), "Delete")
    automate { selenium.get_confirmation() }

    assert_contain("Listing Roles")
    assert_contain("(2)")
    assert_have_no_selector(row_sel(@deletable_role))
    assert_have_selector(".flash_notice", :content => "Role successfully deleted.")

    # Can't delete role that has dependents
    visit_path(admin_roles_path)
    @admin_role.users.should_not be_empty
    click_link_within(row_sel(@admin_role), "Delete")
    automate { selenium.get_confirmation }

    assert_have_selector(row_sel(@admin_role))
    assert_have_selector(".flash_error")
  end

end