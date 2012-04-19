require 'spec_helper'

include RspecIntegrationHelpers

describe "User" do

  fixtures :users

  #before(:each) do
  #  @user = users(:runner)
  #end

  describe "Require attributes" do

    it "requires ldap_uid" do
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
          user.email = "12345"
          user.should have(1).error_on(:email)
        end

      end

      describe "unique" do

        it "succeeds with a unique email" do
          user = User.new
          user.email = "asdfasdfasd@example.com" #TODO this magic constant is any value we know is not in the fixtures
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
        user.ldap_uid = 346 #TODO this magic constant is any value we know is not in the fixtures
        user.should have(0).error_on(:ldap_uid)
      end

      it "fails with a non-unique ldap_uid" do
        user = User.new
        user.ldap_uid = users(:minimal_for_validation).ldap_uid
        user.should have(1).error_on(:ldap_uid)
      end

    end

  end
end


__END__


describe User do
  fixtures(:all)
  
  before(:each) do
    @admin = users(:admin)
  end

  it "should assign all attributes (including protected) when sent protected_attributes=" do
    user = User.new
    attrs = @admin.attributes.delete_if { |k, v| ["id", "updated_at", "created_at"].include?(k) }
    user.protected_attributes = attrs
    attrs.each { |k, v| user.send(k).should == v }
  end

  it "should find by filter when snt #find_from_filter(filter)" do
    # disabled filter
    disabled = User.find_from_filter("disabled")
    disabled.should have(1).user
    disabled[0].email.should == "disabled@berkeley.edu"

    # buyer filter
    buyers = User.find_from_filter("buyers")
    buyers.should have(2).users
    buyers.each { |p| p.roles.map(&:name).include?("buyer").should be_true }
    
    # admin filter
    admins = User.find_from_filter("admins")
    admins.should have(2).users
    admins.each { |p| p.roles.map(&:name).include?("admin").should be_true }

    # Any filter where FILTER !IN FILTER_BY_OPTIONS returns all users
    all = User.find_from_filter("")
    all.should have(7).users

    all = User.find_from_filter(nil)
    all.should have(7).users
    
    all = User.find_from_filter("invalid filter")
    all.should have(7).users
  end

  it "should instantiate new user when sent #new_from_ldap_uid" do
    # user if found, copy attributes over
    user = User.new_from_ldap_uid(@admin.ldap_uid)
    user.new_record?.should be_true
    user.ldap_uid.should == @admin.ldap_uid

    # user is not found, return new untainted user
    user = User.new_from_ldap_uid(nil)
    user.new_record?.should be_true
    user.ldap_uid.should be_nil
  end

  it "should not allow a user to be deleted if it is referenced by other records" do
    runner = users(:runner)
    runner.off_site_requests.should have(2).records
    runner.destroy.should be_false
  end

  it "should allow a user to be deleted if it is not referenced by other records" do
    runner = users(:runner)
    runner.off_site_requests.clear
    runner.save!
    runner.off_site_requests.should be_empty
    runner.destroy.should be_true
  end

end
