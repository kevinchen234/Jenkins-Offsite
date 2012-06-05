require 'spec_helper'

include RspecIntegrationHelpers
include OffSiteRequestIntegrationHelpers


describe "OffSiteRequest CRUD interface" do
  fixtures :all

  #can't stub in before(:all) so changed it to :each for now
  before(:each) do
    @runner = User.find(ActiveRecord::Fixtures.identify(:runner))
    login_user(@runner.ldap_uid)

    @runner_req1 = OffSiteRequest.find(ActiveRecord::Fixtures.identify(:runner_request_1))
    @runner_req2 = OffSiteRequest.find(ActiveRecord::Fixtures.identify(:runner_request_2))
    @ext_one = ExtCircumstance.find(ActiveRecord::Fixtures.identify(:minimal_for_validation))
    simulate { stub_department_list }
  end

  after(:all) { logout_current_user }


  it "should List Off-Site Requests" do
    visit_path(off_site_requests_path)
    assert_contain("Listing Off-Site Requests")
    assert_have_selector(row_sel(@runner_req1))

    # Approved requests have "View" link
    assert_have_selector(row_sel(@runner_req2), :content => "View")
    # Not Approved requests have "Edit" link
    assert_have_selector(row_sel(@runner_req1), :content => "Edit")
  end

  it "should Create an OffSiteRequest" do
    visit_path(off_site_requests_path)
    # automate { selenium.wait_for_page_to_load(5) }
    assert_have_selector("a", :content => "New Request")
    click_link("New Request")
    assert_contain("New Off-Site Request")
    # No delete button for new requests
    assert_have_no_selector("a", :content => "Delete")

    # Confirm errors display when form is invalid
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    # Valid record works
    fill_out_off_site_request_form
    click_button("Submit")
    assert_contain("Edit Off-Site Request")
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_created(OffSiteRequest.new))
  end

  it "should Edit an Off-Site Request" do
    visit_path(off_site_requests_path)
    click_link_within(row_sel(@runner_req1), "Edit")
    assert_contain("Edit Off-Site Request")
    # Should have delete button
    assert_have_selector("a", :content => "Delete")

    # Show error for invalid record
    pre = "off_site_request"
    fill_in("#{pre}_hostname", :with => "")
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    # Can update valid record
    fill_in("#{pre}_hostname", :with => "hostname.berkeley.edu")
    click_button("Submit")
    assert_contain("Edit Off-Site Request")
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_updated(@runner_req1))
  end

  it "should View an Off-Site Request" do
    visit_path(off_site_requests_path)
    click_link_within(row_sel(@runner_req2), "View")
    assert_contain("View Off-Site Request")
    # No delete button for new requests
    assert_have_no_selector("a", :content => "Delete")
    assert_off_site_request_form_is_readonly(@runner_req2)
  end

  it "should Delete an Off-Site Request" do
    visit_path(off_site_requests_path)
    click_link_within(row_sel(@runner_req1), "Edit")
    assert_contain("Edit Off-Site Request")
    click_link("Delete")
    automate { selenium.get_confirmation() }

    assert_contain("Listing Off-Site Requests")
    assert_have_no_selector(row_sel(@runner_req1))
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_destroyed(@runner_req1))
  end
end


describe "authentication before account creation" do
  fixtures(:users)

  it "should prompt user to create account" do
    visit_path(root_path)
    assert_have_selector("a", :content => "Login")
    user = UCB::LDAP::Person.find_by_uid(163289)
    login_user('163289')
    assert_have_selector("div", :content => "Logged in as: #{user.full_name}")
    assert_contain("New User")

    # we get sent back to New User until we create our account
    visit_path(off_site_requests_path)
    assert_contain("New User")
  end
end
