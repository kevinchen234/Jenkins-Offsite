require 'spec_helper'

include RspecIntegrationHelpers

describe "Admin Role CRUD interface" do
  fixtures :all

  before(:all) do
    @admin = User.find(ActiveRecord::Fixtures.identify(:runner))
    login_user(@admin.ldap_uid)

    @not_approved = Status.find(ActiveRecord::Fixtures.identify(:not_approved))
    @approved = Status.find(ActiveRecord::Fixtures.identify(:approved))
  end

  it "should list all statuses" do
    visit_path(admin_statuses_path)
    assert_contain("Listing Status")

    #check for a couple of statuses that should be there, and the buttons they should have
    assert_have_selector(row_sel(@approved), :content => "Edit")
    assert_have_selector(row_sel(@not_approved), :content => "Edit")
  end

  it "should be able to create a new status" do
    visit_path(admin_statuses_path)
    assert_have_selector("a", :content => "New Status")
    click_link("New Status")
    assert_contain("New Status")

    #try and submit invalid form (everything is empty)
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    #fill in fields and try again
    fill_in("status_name", :with => "test status name")
    click_button("Submit")
    assert_contain("Listing Status")
    assert_have_selector(".flash_notice", :content => "Status successfully created.")
  end

  it "should be able to edit a status" do
    visit_path(admin_statuses_path)
    click_link_within(row_sel(@approved), "Edit")
    assert_contain("Edit Status")

    #make name empty and make sure it gives an error
    fill_in("status_name", :with => "")
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    #change name and make sure it stays changed
    fill_in("status_name", :with => "new status name")
    click_button("Submit")
    assert_contain("Listing Status")
    assert_have_selector(".flash_notice", :content => "Status successfully updated.")
    assert_have_selector(row_sel(@approved), :content => "new status name")
  end

end