require "#{File.dirname(__FILE__)}/../spec_helper"

describe OffSiteRequestMailer do
  fixtures(:off_site_requests, :users)
  
  before(:each) do
    @req = off_site_requests(:jack_request_1)
  end

  it "should send email_to_itpolicy for a new request" do
    new_request = true
    msg = OffSiteRequestMailer.create_email_to_itpolicy(@req, new_request)
    msg.body.should match(/request has been created/)
    msg.encoded.should match(/To:.+#{App.itpolicy_email}/)
    msg.encoded.should match(/From:.+admin@offsitehosting.berkeley.edu/)    
  end
  
  it "should send email_to_itpolicy for an updated request" do
    new_request = false
    msg = OffSiteRequestMailer.create_email_to_itpolicy(@req, new_request)
    msg.body.should match(/request has been updated/)
    msg.encoded.should match(/To:.+#{App.itpolicy_email}/)
    msg.encoded.should match(/From:.+admin@offsitehosting.berkeley.edu/)    
  end

  it "should send email_to_campus_official" do
    msg = OffSiteRequestMailer.create_email_to_campus_official(@req)
    msg.encoded.should match(/To:.+#{@req.campus_official.email}/)
    msg.encoded.should match(/From:.+#{App.itpolicy_email}/)    
  end
  
  it "should send email_to_submitter" do
    msg = OffSiteRequestMailer.create_email_to_submitter(@req)
    msg.encoded.should match(/To:.+#{@req.submitter.email}/)
    msg.encoded.should match(/From:.+#{App.itpolicy_email}/)    
  end
end
