require 'spec_helper'

describe "OffSiteRequestObserver on Create" do
  fixtures :statuses, :roles, :users
  
  before(:each) do
    attrs = {
      :hostname => "host.berkeley.edu",
      :hostname_in_use => true,
      :arachne_or_socrates => true,
      :sponsoring_department => "EECS",
      :campus_official_id => 1,
      :off_site_service => "stop.berkeley.edu",
      :for_department_sponsor => true,
      :name_of_group => nil,
      :relationship_of_group => nil,
      :confirmed_service_qualifications => true,
      :sla_reviewed_by => OffSiteRequest::CAMPUS_BUYER,
      :campus_buyer_id => users(:campus_buyer1).id,
      :cns_trk_number => "1234",
      :off_site_ip => "123.123.123.123",
      :meets_ctc_criteria => true
    }
    
    @os_req = OffSiteRequest.new(attrs)
    @os_req.send_email_notification = true    
    @os_req.submitter = users(:runner)
    @os_req.campus_official = users(:campus_official)
  end

  it "should send mail to submitter" do
    OffSiteRequestMailer.should_receive(:deliver_email_to_submitter)
    @os_req.save!
  end
  
  it "should send mail to itpolicy" do
    OffSiteRequestMailer.should_receive(:deliver_email_to_itpolicy)
    @os_req.save!
  end
  
  it "should send mail to campus official" do
    OffSiteRequestMailer.should_receive(:deliver_email_to_campus_official).with(@os_req)
    @os_req.save!
  end
end



describe "OffSiteRequestObserver on Update" do
  fixtures :statuses, :users, :off_site_requests
  
  before(:each) do
    @os_req = off_site_requests(:runner_request_1)
    @os_req.send_email_notification = true
  end

  it "should send mail to itpolicy" do
    OffSiteRequestMailer.should_receive(:deliver_email_to_itpolicy)
    @os_req.hostname = "new.berkeley.edu"
    @os_req.save!
  end
  
  it "should send mail to campus official and cc submitter" do
    OffSiteRequestMailer.should_receive(:deliver_email_to_campus_official).with(@os_req, true).exactly(3).times
    # trigger email if any of these change:
    # [campus_official, sponsoring_department, off_site_service]      
    @os_req.campus_official_id = 2
    @os_req.save!
    @os_req.sponsoring_department = "IST"
    @os_req.save!
    @os_req.off_site_service = "google"
    @os_req.save!

    # doesn't trigger email
    @os_req.off_site_ip = "321.321.321.321"
    @os_req.save!
  end
end

