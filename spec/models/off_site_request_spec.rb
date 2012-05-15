require 'spec_helper'

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

=begin
  before(:each) do

    #attrs = {
    #  :hostname => "host.berkeley.edu",
    #  :hostname_in_use => true,
    #  :arachne_or_socrates => true,
    #  :sponsoring_department => "EECS",
    #  :campus_official_id => 1,
    #  :off_site_service => "stop.berkeley.edu",
    #  :for_department_sponsor => true,
    #  :name_of_group => nil,
    #  :relationship_of_group => nil,
    #  :confirmed_service_qualifications => true,
    #  :cns_trk_number => "1234",
    #  :off_site_ip => "123.123.123.123",
    #  :meets_ctc_criteria => true
    #}

    attrs = {
      :arachne_or_socrates => true,
      :sponsoring_department => "EECS",
      :campus_official_id => 1,
      :off_site_service => "stop.berkeley.edu",
      :cns_trk_number => "1234",
      :off_site_ip => "123.123.123.123",
    }

    minimal_for_validation:
    osr = OffSiteRequest.new(attrs)

    osr.save!
  end
=end

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

    it "should require meets_ctc_criteria" do
      osr = valid
      osr.meets_ctc_criteria = nil
      osr.should_not be_valid
      osr.should have(1).error_on(:meets_ctc_criteria)
    end

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

    describe ":arachne_or_socrates" do

      it "with hostname_in_use, does require arachne_or_socrates" do
        osr = valid
        osr.hostname_in_use = true
        osr.arachne_or_socrates = nil
        osr.should_not be_valid
        osr.should have(1).error_on(:arachne_or_socrates)
      end

      it "without hostname_in_use, does not require arachne_or_socrates" do
        osr = valid
        osr.hostname_in_use = false
        osr.arachne_or_socrates = nil
        osr.should be_valid
        osr.should have(0).error_on(:arachne_or_socrates)
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

    context "with ldap_uid that does exist" do
      before do
        @uid = rand(8888)
        user = User.new
        user.ldap_uid = @uid
        User.stub(:find_by_ldap_uid) { user }
      end

      it "assigns the uid and sets the campus official" do
        osr = valid
        osr.campus_official_ldap_uid = @uid
        osr.campus_official_ldap_uid.should == @uid
        osr.campus_official.should_not be_nil
        osr.campus_official.should eql User.find_by_ldap_uid(@uid)
      end

    end

    context "with ldap_uid that does not exist" do

      before do
        @uid = rand(8888)
      end

      it "throw an error" do
        osr = valid
        User.stub(:find_by_ldap_uid) { nil }
        expect { osr.campus_official_ldap_uid = @uid }.to raise_error(ArgumentError)
      end
    end


  end

end


__END__



describe "should require eligible Campus Official" do

  context "with Ineligible Campus Official: 212372 => AFFILIATE-Normal ###" do

    it "errors" do
      affilate_ldap_uid = 212372 # bogus number guaranteed not to be in db
      if User.find_by_ldap_uid(affilate_ldap_uid)
        raise "Test setup error: the ldap_uid #{affilate_ldap_uid} was found in the db"
      end
      osr.campus_official_ldap_uid = affilate_ldap_uid
                                 # Record was created in Users table
      campus_official = User.find_by_ldap_uid(affilate_ldap_uid)
      campus_official.should_not be_nil
      campus_official.ldap_uid.should eql(affilate_ldap_uid)
                                 # Not valid Campus Official
      osr.should_not be_valid
      osr.should have(1).errors_on(:campus_official_id)
    end
  end


  ### Eligible Campus Official 322585 => EMPLOYEE-Staff ###
  staff_ldap_uid = 322585
  p = UCB::LDAP::Person.find_by_uid(staff_ldap_uid)
  # test ids currently always return expired status so we stub valid affiliations
  p.stub!(:affiliations).and_return(["EMPLOYEE-TYPE-STAFF"])
  UCB::LDAP::Person.stub!(:find_by_uid).and_return(p)
  User.find_by_ldap_uid(staff_ldap_uid).should be_nil
  osr.campus_official_ldap_uid = staff_ldap_uid
  # Record was created in Users table
  campus_official = User.find_by_ldap_uid(staff_ldap_uid)
  campus_official.should_not be_nil
  campus_official.ldap_uid.should eql(staff_ldap_uid)
  # Valid Campus Official
  osr.should be_valid
  osr.should have(0).errors_on(:campus_official_id)
end


  it "should require eligible Submitter" do
    ### Ineligible Submitter: 212372 => AFFILIATE-Normal ###
    affilate_ldap_uid = 212372
    User.find_by_ldap_uid(affilate_ldap_uid).should be_nil
    osr.submitter_ldap_uid = affilate_ldap_uid
    # Record was created in Users table
    submitter = User.find_by_ldap_uid(affilate_ldap_uid)
    submitter.should_not be_nil
    submitter.ldap_uid.should eql(affilate_ldap_uid)
    # Not valid Campus Official
    osr.should_not be_valid
    osr.should have(1).errors_on(:submitter_id)

    
    ### Eligible Submitter 322585 => EMPLOYEE-Staff ###
    staff_ldap_uid = 322585
    p = UCB::LDAP::Person.find_by_uid(staff_ldap_uid)
    # test ids currently always return expired status so we stub valid affiliations
    p.stub!(:affiliations).and_return(["EMPLOYEE-TYPE-STAFF"])
    UCB::LDAP::Person.stub!(:find_by_uid).and_return(p)
    User.find_by_ldap_uid(staff_ldap_uid).should be_nil
    osr.submitter_ldap_uid = staff_ldap_uid
    # Record was created in Users table
    submitter = User.find_by_ldap_uid(staff_ldap_uid)
    submitter.should_not be_nil
    submitter.ldap_uid.should eql(staff_ldap_uid)
    # Valid Campus Official    
    osr.should be_valid
    osr.should have(0).errors_on(:submitter_id)
  end
end


describe "An OffSiteRequest" do
  fixtures :statuses
  
  before(:each) do
    osr = OffSiteRequest.new()
  end



  it "should create Campus Official when setting campus_official_ldap_uid" do
    ### Eligible Campus Official 322585 => EMPLOYEE-Staff ###
    staff_ldap_uid = 322585
    p = UCB::LDAP::Person.find_by_uid(staff_ldap_uid)
    # test ids currently always return expired status so we stub valid affiliations
    p.stub!(:affiliations).and_return(["EMPLOYEE-TYPE-STAFF"])
    UCB::LDAP::Person.stub!(:find_by_uid).and_return(p)
    
    User.find_by_ldap_uid(staff_ldap_uid).should be_nil
    osr.campus_official_ldap_uid = staff_ldap_uid

    campus_official = User.find_by_ldap_uid(staff_ldap_uid)
    campus_official.ldap_uid.should eql(staff_ldap_uid)
  end

  it "should create Submitter when setting submitter_ldap_uid" do
    ### Eligible Submitter 322585 => EMPLOYEE-Staff ###
    staff_ldap_uid = 322585
    p = UCB::LDAP::Person.find_by_uid(staff_ldap_uid)
    # test ids currently always return expired status so we stub valid affiliations
    p.stub!(:affiliations).and_return(["EMPLOYEE-TYPE-STAFF"])
    UCB::LDAP::Person.stub!(:find_by_uid).and_return(p)
    
    User.find_by_ldap_uid(staff_ldap_uid).should be_nil
    osr.submitter_ldap_uid = staff_ldap_uid

    submitter = User.find_by_ldap_uid(staff_ldap_uid)
    submitter.ldap_uid.should eql(staff_ldap_uid)
  end


end



