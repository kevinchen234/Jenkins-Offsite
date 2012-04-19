require 'spec_helper'

describe "OffSiteRequest validation" do
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
      :cns_trk_number => "1234",
      :off_site_ip => "123.123.123.123",
      :meets_ctc_criteria => true
    }
    
    @os_req = OffSiteRequest.new(attrs)
    @os_req.submitter_id = 1
    @os_req.campus_official_id = 1
    @os_req.save!
  end

  it "should be valid" do
    @os_req.should be_valid
  end
  
  it "should require a submitter" do
    @os_req.submitter_id = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:submitter_id)
  end
  
  it "should require a hostname" do
    @os_req.hostname = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:hostname)
  end
  
  it "should require a unique hostname" do
    new_req = OffSiteRequest.new()
    new_req.hostname = "off.berkeley.edu"
    new_req.valid?
    new_req.should have(0).error_on(:hostname)

    new_req.hostname = @os_req.hostname
    new_req.should_not be_valid
    new_req.should have(1).error_on(:hostname)
  end  
  
  it "should require hostname to end with .berkeley.edu" do
    func = lambda { |obj, name|
      obj.send(:hostname=, name)
      obj.send(:should_not, be_valid)
      obj.send(:should, have(1).error_on(:hostname))
    }

    [".edu", ".berkeley" ".berkeleyedu", ".com", ".berkeley.edu.com"].each do |n|
      func.call(@os_req, "site#{n}")
    end

    @os_req.hostname = "site.berkeley.edu"
    @os_req.should be_valid
    @os_req.should have(0).errors_on(:hostname)
  end  
  
  it "should require hostname_in_use" do
    @os_req.hostname_in_use = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:hostname_in_use)
  end
  
  it "should require sponsoring_department" do
    @os_req.sponsoring_department = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:sponsoring_department)
  end
  
  it "should require for_department_sponsor" do
    @os_req.for_department_sponsor = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:for_department_sponsor)
  end
  
  it "should require off_site_service" do
    @os_req.off_site_service = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:off_site_service)
  end
  
  it "should require confirmed_service_qualifications" do
    @os_req.confirmed_service_qualifications = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:confirmed_service_qualifications)
  end
  
  it "should require campus_official" do
    @os_req.campus_official_id = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:campus_official_id)
  end

  it "should require meets_ctc_criteria" do
    @os_req.meets_ctc_criteria = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:meets_ctc_criteria)
  end  
  
  
  it "should conditionally require name_of_group" do
    # required  only if for_department_sponsor === false
    @os_req.for_department_sponsor = false
    @os_req.name_of_group = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:name_of_group)

    @os_req.for_department_sponsor = true
    @os_req.name_of_group = nil
    @os_req.should be_valid
    @os_req.should have(0).error_on(:name_of_group)
  end
  
  it "should conditionally require relationship_of_group" do
    # required  only if for_department_sponsor === false
    @os_req.for_department_sponsor = false
    @os_req.relationship_of_group = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:relationship_of_group)

    @os_req.for_department_sponsor = true
    @os_req.relationship_of_group = nil
    @os_req.should be_valid
    @os_req.should have(0).error_on(:relationship_of_group)
  end
  
  it "should conditionally require arachne_or_socrates" do
    # required only if hostname_in_use == true
    @os_req.hostname_in_use = true
    @os_req.arachne_or_socrates = nil
    @os_req.should_not be_valid
    @os_req.should have(1).error_on(:arachne_or_socrates)

    @os_req.hostname_in_use = false
    @os_req.arachne_or_socrates = nil
    @os_req.should be_valid
    @os_req.should have(0).error_on(:arachne_or_socrates)
  end

  
  it "should not require off_site_ip" do
    @os_req.off_site_ip = nil
    @os_req.should be_valid
    @os_req.should have(0).error_on(:off_site_ip)
  end
  
  it "should not require cns_trk_number" do
    @os_req.cns_trk_number = nil
    @os_req.should be_valid
    @os_req.should have(0).error_on(:cns_trk_number)
  end


  it "should enforce correct formatting off_site_ip" do
    mal_ips = ["123", "123.123", "123.123.123.123.123", "hi"]
    mal_ips.each do |ip|
      @os_req.off_site_ip = ip
      @os_req.should_not be_valid
      @os_req.should have(1).error_on(:off_site_ip)
    end
  end

  it "should require eligible Campus Official" do
    ### Ineligible Campus Official: 212372 => AFFILIATE-Normal ###
    affilate_ldap_uid = 212372
    User.find_by_ldap_uid(affilate_ldap_uid).should be_nil
    @os_req.campus_official_ldap_uid = affilate_ldap_uid
    # Record was created in Users table
    campus_official = User.find_by_ldap_uid(affilate_ldap_uid)
    campus_official.should_not be_nil
    campus_official.ldap_uid.should eql(affilate_ldap_uid)
    # Not valid Campus Official
    @os_req.should_not be_valid
    @os_req.should have(1).errors_on(:campus_official_id)

    
    ### Eligible Campus Official 322585 => EMPLOYEE-Staff ###
    staff_ldap_uid = 322585
    p = UCB::LDAP::Person.find_by_uid(staff_ldap_uid)
    # test ids currently always return expired status so we stub valid affiliations
    p.stub!(:affiliations).and_return(["EMPLOYEE-TYPE-STAFF"])
    UCB::LDAP::Person.stub!(:find_by_uid).and_return(p)
    User.find_by_ldap_uid(staff_ldap_uid).should be_nil
    @os_req.campus_official_ldap_uid = staff_ldap_uid
    # Record was created in Users table
    campus_official = User.find_by_ldap_uid(staff_ldap_uid)
    campus_official.should_not be_nil
    campus_official.ldap_uid.should eql(staff_ldap_uid)
    # Valid Campus Official    
    @os_req.should be_valid
    @os_req.should have(0).errors_on(:campus_official_id)
  end

  it "should require eligible Submitter" do
    ### Ineligible Submitter: 212372 => AFFILIATE-Normal ###
    affilate_ldap_uid = 212372
    User.find_by_ldap_uid(affilate_ldap_uid).should be_nil
    @os_req.submitter_ldap_uid = affilate_ldap_uid
    # Record was created in Users table
    submitter = User.find_by_ldap_uid(affilate_ldap_uid)
    submitter.should_not be_nil
    submitter.ldap_uid.should eql(affilate_ldap_uid)
    # Not valid Campus Official
    @os_req.should_not be_valid
    @os_req.should have(1).errors_on(:submitter_id)

    
    ### Eligible Submitter 322585 => EMPLOYEE-Staff ###
    staff_ldap_uid = 322585
    p = UCB::LDAP::Person.find_by_uid(staff_ldap_uid)
    # test ids currently always return expired status so we stub valid affiliations
    p.stub!(:affiliations).and_return(["EMPLOYEE-TYPE-STAFF"])
    UCB::LDAP::Person.stub!(:find_by_uid).and_return(p)
    User.find_by_ldap_uid(staff_ldap_uid).should be_nil
    @os_req.submitter_ldap_uid = staff_ldap_uid
    # Record was created in Users table
    submitter = User.find_by_ldap_uid(staff_ldap_uid)
    submitter.should_not be_nil
    submitter.ldap_uid.should eql(staff_ldap_uid)
    # Valid Campus Official    
    @os_req.should be_valid
    @os_req.should have(0).errors_on(:submitter_id)
  end
end


describe "An OffSiteRequest" do
  fixtures :statuses
  
  before(:each) do
    @os_req = OffSiteRequest.new()
  end

  it "should default status to [Not Approved]" do
    @os_req.status.should eql(statuses(:not_approved))
  end

  it "should create Campus Official when setting campus_official_ldap_uid" do
    ### Eligible Campus Official 322585 => EMPLOYEE-Staff ###
    staff_ldap_uid = 322585
    p = UCB::LDAP::Person.find_by_uid(staff_ldap_uid)
    # test ids currently always return expired status so we stub valid affiliations
    p.stub!(:affiliations).and_return(["EMPLOYEE-TYPE-STAFF"])
    UCB::LDAP::Person.stub!(:find_by_uid).and_return(p)
    
    User.find_by_ldap_uid(staff_ldap_uid).should be_nil
    @os_req.campus_official_ldap_uid = staff_ldap_uid

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
    @os_req.submitter_ldap_uid = staff_ldap_uid

    submitter = User.find_by_ldap_uid(staff_ldap_uid)
    submitter.ldap_uid.should eql(staff_ldap_uid)
  end

  it "should not be deleted if it is approved" do
    @runner_req2 = OffSiteRequest.find(Fixtures.identify(:runner_request_2))
    @runner_req2.status.approved?.should be_true
    @runner_req2.destroy.should be_false
    @runner_req2.errors.should_not be_empty

    # change status then we can delete
    @runner_req2.status = Status.find(Fixtures.identify(:not_approved))
    @runner_req2.save!
    @runner_req2.destroy.should be_true
  end
end


describe "OffSiteRequest CSV Export" do
  fixtures :statuses, :off_site_requests
  
  before(:each) do
    @os_req = off_site_requests(:runner_request_1)
  end

  it "should have same header cols as attributes csv col header" do
    @os_req.class.csv_header_cols.should == @os_req.csv_attributes.keys.sort
  end
end

