require 'spec_helper'

include RspecIntegrationHelpers

describe "User" do

  fixtures :users
  fixtures :off_site_requests

  describe "Require attributes" do

    it "requires ldap_uid" do
      puts users
      should_require_attr(users(:minimal_for_attributes), :ldap_uid)
    end

    it "requires first_name" do
      should_require_attr(users(:minimal_for_attributes), :first_name)
    end

    it "requires last_name" do
      should_require_attr(users(:minimal_for_attributes), :last_name)
    end

    it "requires email" do
      should_require_attr(users(:minimal_for_attributes), :email)
    end

    it "requires enabled" do
      should_require_attr(users(:minimal_for_attributes), :enabled, 2)
    end

  end

  describe "User validation" do

    it "is valid" do
      users(:minimal_for_validation).should be_valid
    end

    describe "#email" do

      describe "formatting" do

        it "succeeds with a properly formatted email" do
          user = User.new
          user.email = "foo@example.com"
          user.should have(0).error_on(:email)
        end

        it "fails with an improperly formatted email" do
          user = User.new
          user.email = "fooexample.com"
          user.should have(1).error_on(:email)
        end

      end

      describe "unique" do

        it "succeeds with a unique email" do
          user = User.new
          user.email = "asdfasdfasd@example.com" #TODO: this magic constant is any value we know is not in the fixtures
          user.should have(0).error_on(:email)
        end

        it "fails with a non-unique email" do
          user = User.new
          user.ldap_uid = users(:minimal_for_validation).email
          user.should have(1).error_on(:email)
        end

      end

    end

    describe "#ldap_uid" do

      it "succeeds with a unique ldap_uid" do
        user = User.new
        user.ldap_uid = 346 #TODO: this magic constant is any value we know is not in the fixtures
        user.should have(0).error_on(:ldap_uid)
      end

      it "fails with a non-unique ldap_uid" do
        user = User.new
        user.ldap_uid = users(:minimal_for_validation).ldap_uid
        user.should have(1).error_on(:ldap_uid)
      end

    end

  end

  describe "#protected_attributes" do

    it "enabled" do
      user = User.new
      user.protected_attributes={:enabled => true}
      user.enabled.should == true
      user.protected_attributes={:enabled => false}
      user.enabled.should == false
    end

    it "ldap_uid" do
      user = User.new
      user.protected_attributes={:ldap_uid => 12345}
      user.ldap_uid.should == 12345
      user.protected_attributes={:ldap_uid => nil}
      user.ldap_uid.should == nil
    end

    #TODO Deprecated
    #it "role_id" do
    #  user = User.new
    #  user.protected_attributes={:role_ids => 1}
    #  user.role_ids.should == 1
    #end

    #TODO Deprecated
    #it "should assign accessible attributes" do
    #  user = users(:minimal_for_validation)
    #  attrs = @admin.attributes.keep_if { |k, v| accessible_attributes.include?(k) }
    #  user.protected_attributes = attrs
    #  attrs.each { |k, v| user.send(k).should == v }
    #end

  end

  describe "#find_from_filter" do

    context "with recognized param" do

      it "disabled returns User.disabled" do
        User.should_receive(:disabled)
        User.find_from_filter("disabled")
      end

      it "buyers returns User.campus_buyers" do
        User.should_receive(:campus_buyers)
        User.find_from_filter("buyers")
      end

      it "admins returns User.admins" do
        User.should_receive(:admins)
        User.find_from_filter("admins")
      end

    end

    context "without recognized param" do

      it "blank returns User.all" do
        User.should_receive(:all)
        User.find_from_filter("")
      end

      it "nil returns User.all" do
        User.should_receive(:all)
        User.find_from_filter(nil)
      end

      it "any filter string that is not in FILTER_BY_OPTIONS returns User.all" do
        User.should_receive(:all)
        User.find_from_filter("foobar")
      end

    end

  end

  describe "#new_from_ldap_uid" do

    context "with a ldap_uid that is found in ldap" do

      it "finds the ldap record and returns a new user with the ldap_uid set" do
        ldap_uid = 114027 # users(:minimal_for_validation).ldap_uid
        #ldap = double("UCB::LDAP::Person")
        #ldap.stub(:find_by_uid).with(:ldap_uid)
        user = User.new_from_ldap_uid(ldap_uid)
        user.new_record?.should be_true
        user.ldap_uid.should == ldap_uid
      end

    end

    context "with nil" do

      #TODO: figure out what's happening with this method and nil-- in earlier code,
      #this would create a fresh user record e.g. User.new. We think it's better to
      #instead return nil, e.g. to let the controller create a new User if needed.
      it "returns nil" do
        user = User.new_from_ldap_uid(nil)
        user.should be_nil
      end

    end
  end

  describe "#destroy has referential integrity" do

    it "should not allow a user to be deleted if it is referenced by other records" do
      user = users(:minimal_for_validation)
      osr = off_site_requests(:minimal_for_validation)
      user.off_site_requests << osr
      user.save!
      user.off_site_requests.should have(1).records
      lambda {user.destroy}.should raise_error DestroyWithReferencesError
     end

    it "should allow a user to be deleted if it is not referenced by other records" do
      user = users(:minimal_for_validation)
      user.off_site_requests.clear
      user.save!
      user.off_site_requests.should be_empty
      user.destroy.should be_true
    end
  end

end

