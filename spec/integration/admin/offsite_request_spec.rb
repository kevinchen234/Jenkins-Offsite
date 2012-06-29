require 'spec_helper'

include RspecIntegrationHelpers
include OffSiteRequestIntegrationHelpers


describe "Admin::OffSiteRequest CRUD interface" do
  fixtures(:all)

  before(:each) do
    login_user(@admin =  User.find(ActiveRecord::Fixtures.identify(:runner)))
    @approved_request = OffSiteRequest.find(ActiveRecord::Fixtures.identify(:approved_request))
    @not_approved_request = OffSiteRequest.find(ActiveRecord::Fixtures.identify(:not_approved_request))
    # stub_department_list
    simulate { stub_department_list }

  end

  after(:all) { logout_current_user }


  it "should List Off-Site Requests" do
    visit_path(admin_off_site_requests_path)
    assert_contain("Listing Off-Site Requests")
    assert_have_selector(row_sel(@not_approved_request))
    assert_have_selector(row_sel(@approved_request))
  end

  it "should Export Off-Site Requests to Spreadsheet" do
    visit_path(admin_off_site_requests_path)
    click_link("Export to Spreadsheet")

    simulate do
      lines = response_body.split("\n")
      # 1 header + 3 off_site_requests
      lines.should have(4).items
    end
  end

  it "should Create an OffSiteRequest" do
    visit_path(admin_off_site_requests_path)
    click_link("New Request")
    # defaults to enforcing validation

    simulate { assert_have_selector("input[id='off_site_request_enforce_validation_true'][checked='checked']") }
    automate { assert_have_selector("input[id='off_site_request_enforce_validation_true']:checked") }

    # Displays errors if record invalid
    click_button("Submit")
    assert_have_selector(".errorExplanation")

    # Disable validation saves no matter what
    choose("off_site_request_enforce_validation_false")
    click_button("Submit")
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_created(OffSiteRequest.new))
    assert_contain("Edit Off-Site Request")

    # Valid record gets saved
    visit_path(admin_off_site_requests_path)
    click_link("New Request")
    fill_out_admin_off_site_request_form
    click_button("Submit")
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_created(OffSiteRequest.new))
    assert_contain("Edit Off-Site Request")
  end

  it "should Edit an Off-Site Request" do
    visit_path(admin_off_site_requests_path)
    assert_have_selector(row_sel(@not_approved_request), :content => "runner.berkeley.edu")
    click_link_within(row_sel(@not_approved_request), "Edit")
    assert_contain("Edit Off-Site Request")

    # Displays error when required field is missing
    fill_in("off_site_request_hostname", :with => "")
    click_button("Submit")
    assert_have_selector("#errorExplanation")
    assert_contain("Edit Off-Site Request")

    # Disable validation updates no matter what
    choose("off_site_request_enforce_validation_false")
    click_button("Submit")
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_updated(OffSiteRequest.new))
    assert_contain("Edit Off-Site Request")

    # Updates valid record
    fill_in("off_site_request_hostname", :with => "runner-new.berkeley.edu")
    click_button("Submit")
    assert_contain("Edit Off-Site Request")
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_updated(@not_approved_request))
    assert_have_selector("input[id=off_site_request_hostname][value='runner-new.berkeley.edu']")
  end

  it "should Delete an Off-Site Request" do
    # Can't delete approved requests
    visit_path(admin_off_site_requests_path)
    click_link_within(row_sel(@approved_request), "Edit")
    assert_contain("Edit Off-Site Request")
    click_link("Delete")
    automate { selenium.get_confirmation }

    assert_contain("Edit Off-Site Request")
    assert_have_selector(".flash_error")

    # Now we can delete
    select("Not Approved", :from => "off_site_request_status_id")
    click_button("Submit")
    automate { selenium.wait_for_page_to_load }
    assert_have_selector(".flash_notice", :content => CrudMessage.msg_updated(@approved_request))

    click_link("Delete")
    automate { selenium.get_confirmation }
    assert_contain("Listing Off-Site Requests")
    assert_have_no_selector(row_sel(@approved_request))
  end
end
