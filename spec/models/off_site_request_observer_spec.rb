require 'spec_helper'

describe "OffSiteRequestObserver" do
  fixtures :statuses, :roles, :users

  let(:valid_user) { users(:minimal_for_validation) }
  let(:campus_official) { users(:minimal_for_validation) }
  let(:attrs) { {
      :hostname => "host.berkeley.edu",
      :hostname_in_use => true,
      :sponsoring_department => "EECS",
      :off_site_service => "stop.berkeley.edu",
      :for_department_sponsor => true,
      :name_of_group => nil,
      :relationship_of_group => nil,
      :confirmed_service_qualifications => true,
      :campus_buyer_id => valid_user.id,
      :off_site_ip => "123.123.123.123",
      :additional_DNS_instructions => nil
  } }
  let(:osr) {
    osr = OffSiteRequest.new(attrs)
    osr.campus_official_id = users(:minimal_for_validation).id
    osr.send_email_notification = true
    osr.submitter = valid_user

    #now protected attributes
    osr.sla_reviewed_by = OffSiteRequest::CAMPUS_BUYER
    osr.cns_trk_number = "1234"

    osr
  }

  describe "Create" do

    before(:each) do
      @osr = osr
      @osr.campus_official = campus_official
    end

    it "sends email to submitter" do
      OffSiteRequestMailer.should_receive(:email_to_submitter)
      @osr.save!
    end

    it "sends email to it policy" do
      OffSiteRequestMailer.should_receive(:email_to_it_policy)
      @osr.save!
    end

    it "sends email to campus official" do
      OffSiteRequestMailer.should_receive(:email_to_campus_official).with(osr)
      @osr.save!
    end
  end


  describe "Update" do

    before(:each) do
      OffSiteRequestMailer.stub(:email_to_it_policy)
      OffSiteRequestMailer.stub(:email_to_campus_official)
      @osr = osr
    end

    it "sends email to it policy" do
      OffSiteRequestMailer.should_receive(:email_to_it_policy).with(osr, true).exactly(1).times
      @osr.hostname = "new.berkeley.edu"
      @osr.save!
    end

    describe "does or doesn't send email to campus official and cc submitter when fields change" do

      before(:each) do
        @osr.save!
      end

      it "campus official => send" do
        OffSiteRequestMailer.should_receive(:email_to_campus_official).with(osr, true).exactly(1).times
        @osr.campus_official_id = 2
        @osr.save!
      end

      it "sponsoring department => send" do
        OffSiteRequestMailer.should_receive(:email_to_campus_official).with(osr, true).exactly(1).times
        @osr.sponsoring_department = "IST"
        @osr.save!
      end

      it "off site service => send" do
        OffSiteRequestMailer.should_receive(:email_to_campus_official).with(osr, true).exactly(1).times
        @osr.off_site_service = "google"
        @osr.save!
      end

      it "off site ip => do not send" do
        OffSiteRequestMailer.should_not_receive(:email_to_campus_official)
        @osr.off_site_ip = "321.321.321.321"
        @osr.save!
      end

    end

  end

end