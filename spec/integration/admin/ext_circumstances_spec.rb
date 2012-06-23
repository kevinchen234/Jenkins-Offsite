require 'spec_helper'

include RspecIntegrationHelpers

describe "Admin Ext. Circumstances CRUD interface" do
  fixtures :all

  before(:all) do
    @admin = User.find(ActiveRecord::Fixtures.identify(:runner))
    login_user(@admin.ldap_uid)

    @circumstance = ExtCircumstance.find(ActiveRecord::Fixtures.identify(:minimal_for_validation))
  end

  it "should list all ext circumstances" do
    visit_path(admin_ext_circumstances_path)
    assert_contain("Listing Extenuating Circumstances")

    #check for a circumstance that should be there, and the buttons it should have
    assert_have_selector(row_sel(@circumstance), :content => "Edit")
    assert_have_selector(row_sel(@circumstance), :content => "Delete")

  end

  it "should be able to create a new circumstance" do
    visit_path(admin_ext_circumstances_path)
    assert_have_selector("a", :content => "New Circumstance")
    click_link("New Circumstance")
    assert_contain("New Extenuating Circumstance")

    #try and submit invalid form (everything is empty)
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    #fill in fields and try again
    fill_in("ext_circumstance_description", :with => "test circumstance")
    click_button("Submit")
    assert_contain("Listing Extenuating Circumstances")
    assert_have_selector(".flash_notice", :content => "ExtCircumstance successfully created.")
  end

  it "should be able to edit a circumstance" do
    visit_path(admin_ext_circumstances_path)
    click_link_within(row_sel(@circumstance), "Edit")
    assert_contain("Edit Extenuating Circumstance")

    #make description empty and see that it doesn't change it
    fill_in("ext_circumstance_description", :with => "")
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    #make a different description and see that it changes
    fill_in("ext_circumstance_description", :with => "This is a new circumstance description")
    click_button("Submit")
    assert_contain("Listing Extenuating Circumstances")
    assert_have_selector(".flash_notice", :content => "ExtCircumstance successfully updated.")
    assert_have_selector(row_sel(@circumstance), :content => "This is a new circumstance description")
  end

  it "should be able to delete a role" do
    visit_path(admin_ext_circumstances_path)
    click_link_within(row_sel(@circumstance), "Delete")
    automate { selenium.get_confirmation() }

    assert_contain("Listing Extenuating Circumstances")
    assert_have_no_selector(row_sel(@circumstance))
    assert_have_selector(".flash_notice", :content => "ExtCircumstance successfully deleted.")
  end

end