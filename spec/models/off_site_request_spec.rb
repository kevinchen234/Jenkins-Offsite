require 'spec_helper'

class << Rails.logger
  def flush_error(message)
    Rails.logger.error message
    Rails.logger.flush
  end
end

describe "OffSiteRequest" do
  fixtures :off_site_requests, :statuses, :roles, :users

  LDAP_UID_NOT_IN_DB = 212372

  let(:valid) {
    osr = off_site_requests(:minimal_for_validation)
    osr.submitter_id = 1
    osr.campus_official_id = 1
    osr
  }

  let(:valid_user) { users(:minimal_for_validation) }

  let(:ldap_person) {
    ldap_person = UCB::LDAP::Person.new({})
    ldap_person.stub(:uid) { rand(8888) }
    ldap_person.stub(:first_name) { "first_name_123" }
    ldap_person.stub(:last_name) { "last_name_123" }
    ldap_person.stub(:email) { "person@example.com" }
    ldap_person.stub(:berkeleyeduunithrdeptname) { "ABCDE" }
    ldap_person.stub(:phone) { "123-456-7890" }
    ldap_person
  }

  describe "validation" do

    it "should be valid" do
      valid.should be_valid
    end

    it "should require a submitter" do
      osr = valid
      osr.submitter_id = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:submitter_id)
    end

    it "should require a hostname" do
      osr = valid
      osr.hostname = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:hostname)
    end

    it "should require a unique hostname" do
      osr = OffSiteRequest.new()
      osr.hostname = "off.berkeley.edu"
      osr.valid?
      osr.should have(0).error_on(:hostname)

      osr.hostname = valid.hostname
      osr.should_not be_valid
      osr.should have(1).error_on(:hostname)
    end

    it "should require hostname to end with .berkeley.edu" do
      osr = valid

      [".edu", ".berkeley" ".berkeleyedu", ".com", ".berkeley.edu.com"].each do |hostname|
        osr.hostname = hostname
        osr.should_not be_valid
        osr.should have(1).error_on(:hostname)
      end

      osr.hostname = "site.berkeley.edu"
      osr.should be_valid
      osr.should have(0).errors_on(:hostname)
    end


    it "should require hostname_in_use" do
      osr = valid
      osr.hostname_in_use = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:hostname_in_use)
    end

    it "should require sponsoring_department" do
      osr = valid
      osr.sponsoring_department = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:sponsoring_department)
    end

    it "should require for_department_sponsor" do
      osr = valid
      osr.for_department_sponsor = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:for_department_sponsor)
    end

    it "should require off_site_service" do
      osr = valid
      osr.off_site_service = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:off_site_service)
    end

    it "should require confirmed_service_qualifications" do
      osr = valid
      osr.confirmed_service_qualifications = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:confirmed_service_qualifications)
    end

    it "should require campus_official" do
      osr = valid
      osr.campus_official_id = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:campus_official_id)
    end
=begin
    it "should require meets_ctc_criteria" do
      osr = valid
      osr.meets_ctc_criteria = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:meets_ctc_criteria)
    end
=end

    describe ":name_of_group" do

      it "with department sponsor, does not require name_of_group" do
        osr = valid
        osr.for_department_sponsor = true
        osr.name_of_group = nil
        osr.should be_valid
        osr.should have(0).error_on(:name_of_group)
      end

      it "without department sponsor, does require name_of_group" do
        osr = valid
        osr.for_department_sponsor = false
        osr.name_of_group = nil
        osr.should_not be_valid
        osr.should have(1).error_on(:name_of_group)
      end

    end

    describe ":relationship_of_group" do

      it "without department_sponsor, does require relationship_of_group" do
        osr = valid
        osr.for_department_sponsor = false
        osr.relationship_of_group = nil
        osr.should_not be_valid
        osr.should have(1).error_on(:relationship_of_group)
      end

      it "with department sponsor, does not require relationship_of_group" do
        osr = valid
        osr.for_department_sponsor = true
        osr.relationship_of_group = nil
        osr.should be_valid
        osr.should have(0).error_on(:relationship_of_group)
      end

    end

    #describe ":arachne_or_socrates" do
    #
    #  it "with hostname_in_use, does require arachne_or_socrates" do
    #    osr = valid
    #    osr.hostname_in_use = true
    #    osr.arachne_or_socrates = nil
    #    osr.should_not be_valid
    #    osr.should have(1).error_on(:arachne_or_socrates)
    #  end
    #
    #  it "without hostname_in_use, does not require arachne_or_socrates" do
    #    osr = valid
    #    osr.hostname_in_use = false
    #    osr.arachne_or_socrates = nil
    #    osr.should be_valid
    #    osr.should have(0).error_on(:arachne_or_socrates)
    #  end
    #
    #end

    describe ":status" do

      it "status must not be nil" do
        osr = valid
        osr.status = nil
        osr.valid?
        osr.errors.should_not be_empty
      end

      it "status must exist" do
        osr = valid
        osr.status_id = -1
        osr.valid?
        osr.errors.should_not be_empty
      end

    end

    it "should not require off_site_ip" do
      osr = valid
      osr.off_site_ip = nil
      osr.should be_valid
      osr.should have(0).error_on(:off_site_ip)
    end

    it "should not require cns_trk_number" do
      osr = valid
      osr.cns_trk_number = nil
      osr.should be_valid
      osr.should have(0).error_on(:cns_trk_number)
    end

    it "should not require additional_DNS_instructions" do
      osr = valid
      osr.additional_DNS_instructions = nil
      osr.should be_valid
      osr.should have(0).error_on(:additional_DNS_instructions)
    end

    it "should enforce correct formatting off_site_ip" do
      osr = valid
      mal_ips = ["123", "123.123", "123.123.123.123.123", "hi"]
      mal_ips.each do |ip|
        osr.off_site_ip = ip
        osr.should_not be_valid
        osr.should have(1).error_on(:off_site_ip)
      end
    end

    it "should not be deleted if it is approved" do
      osr = valid
      osr.status = Status::APPROVED
      osr.destroy.should be_false
      osr.errors.should_not be_empty
    end

    it "should be deleted if it is not approved" do
      osr = valid
      osr.status = Status::NOT_APPROVED
      osr.destroy.should be_true
      osr.errors.should be_empty
    end


    describe "#validate_campus_official" do
      it "should have a campus official that is eligible" do
        osr = valid
        osr.stub(:campus_official) { valid_user }
        osr.stub(:campus_official_eligible?) { false }
        osr.validate_campus_official
        osr.errors.should_not be_empty
      end
    end

    describe "#validate_submitter" do
      it "should have a submitter that is eligible" do
        osr = valid
        osr.stub(:submitter) { valid_user }
        osr.stub(:submitter_eligible?) { false }
        osr.validate_submitter
        osr.errors.should_not be_empty
      end
    end

  end

  describe "CSV Export" do

    it "should have same header cols as attributes csv col header" do
      osr = valid
      osr.class.csv_header_cols.should == osr.csv_attributes.keys.sort
    end
  end

  describe "default values" do
    it "should default status to [Not Approved]" do
      osr = OffSiteRequest.new
      osr.status.should eql(Status::NOT_APPROVED)
    end

  end

  describe "#campus_official_ldap_uid" do

    before do
      @uid = rand(8888)
    end

    context "with a local database user" do

      before do
        #user = User.new #not sure if this was original or not. This doesn't make sense when saving new users
        user = valid_user
        user.ldap_uid = @uid
        User.stub(:find_by_ldap_uid) { user }
      end

      it "assigns the uid and sets the campus official" do
        osr = valid
        osr.campus_official_ldap_uid = @uid
        osr.campus_official_ldap_uid.should == @uid
        osr.campus_official.should_not be_nil
        osr.campus_official.should be_a User
        osr.campus_official.should eql User.find_by_ldap_uid(@uid)
      end

    end

    context "without a local database user" do

      before do
        User.stub(:find_by_ldap_uid) { nil }
      end

      context "with a remote ldap user" do

        before do
          @uid = ldap_person.uid
          UCB::LDAP::Person.stub(:find_by_uid) { ldap_person }
        end

        it "creates a local database user using the remote ldap user" do
          Rails.logger.debug "creates"
          osr = valid
          osr.campus_official_ldap_uid = @uid
          osr.campus_official_ldap_uid.should == @uid
          osr.campus_official.should_not be_nil
          osr.campus_official.should be_a User
          osr.campus_official.last_name.should eql ldap_person.last_name
        end

      end

      #context "without a remote ldap user" do
      #
      #  before do
      #    UCB::LDAP::Person.stub(:find_by_uid) { nil }
      #  end
      #
      #  it "throw an error" do
      #    osr = valid
      #    expect { osr.campus_official_ldap_uid = @uid }.to raise_error(ArgumentError)
      #  end
      #end

    end

  end

  describe "#submitter_ldap_uid" do

    before do
      @uid = rand(8888)
    end

    context "with a local database user" do

      before do
        user = valid_user
        user.ldap_uid = @uid
        User.stub(:find_by_ldap_uid) { user }
      end

      it "assigns the uid and sets the submitter" do
        osr = valid
        osr.submitter_ldap_uid = @uid
        osr.submitter_ldap_uid.should == @uid
        osr.submitter.should_not be_nil
        osr.submitter.should be_a User
        osr.submitter.should eql User.find_by_ldap_uid(@uid)
      end

    end

    context "without a local database user" do

      before do
        User.stub(:find_by_ldap_uid) { nil }
      end

      context "with a remote ldap user" do

        before do
          @uid = ldap_person.uid
          UCB::LDAP::Person.stub(:find_by_uid) { ldap_person }
        end

        it "creates a local database user using the remote ldap user" do
          Rails.logger.debug "creates"
          osr = valid
          osr.submitter_ldap_uid = @uid
          osr.submitter_ldap_uid.should == @uid
          osr.submitter.should_not be_nil
          osr.submitter.should be_a User
          osr.submitter.last_name.should eql ldap_person.last_name
        end

      end

      #context "without a remote ldap user" do
      #
      #  before do
      #    UCB::LDAP::Person.stub(:find_by_uid) { nil }
      #  end
      #
      #  it "throw an error" do
      #    osr = valid
      #    expect { osr.submitter_ldap_uid = @uid }.to raise_error(ArgumentError)
      #  end
      #end

    end

  end


end


