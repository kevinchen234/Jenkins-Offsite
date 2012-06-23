require 'spec_helper'

describe OffSiteRequestsController do
  fixtures :all

  let(:current_user) { mock_model(User).as_null_object }
  let(:mock_os_req) {mock_model(OffSiteRequest) }
  let(:mock_req_list) { [mock_model(OffSiteRequest)]}
  let(:built_req) {mock_model(OffSiteRequest)}
  let(:mock_ldap_person) { UCB::LDAP::Person.new([]) }
  let(:reqs) { OffSiteRequest.all }

  before(:each) do
    mock_ldap_person.stub(:uid).and_return(0101010)
    controller.stub(:ldap_user).and_return(mock_ldap_person)
    controller.stub(:current_user).and_return(current_user)
  end

  describe "GET index" do
    it "sets @os_reqs to be a list of the current users requests" do
      current_user.should_receive(:off_site_requests).and_return(mock_req_list)
      get 'index'
      assigns[:os_reqs].should eq(mock_req_list)
    end
  end

  describe "GET new" do
    it "sets @os_req to be a newly built off site request" do
      current_user.should_receive(:off_site_requests).and_return(mock_os_req)
      mock_os_req.should_receive(:build).and_return(built_req)
      get 'new'
      assigns[:os_req].should eq(built_req)
    end
  end


  #Not sure how to handle deleting @os_req when it is loaded in load_os_req before_filter
  describe "DELETE destroy" do

    before(:each) do
      current_user.stub(:off_site_requests).and_return(mock_req_list)
      mock_req_list.stub(:find).with("769434382").and_return(mock_os_req)
    end

    it "destroys @os_req" do
      #current_user.stub(:off_site_requests).and_return(OffSiteRequest.all)
      #mock_req_list.stub(:find).with("769434382")
      mock_os_req.should_receive(:destroy).and_return(true)
      delete 'destroy', :id => 769434382
    end

    it "gives a message in the flash" do
      delete 'destroy', :id => 769434382
      flash[:notice].should eq("#{assigns[:os_req].class} successfully deleted.")
    end

    it "redirects to the requests url" do
      delete 'destroy', :id => 769434382
      response.should redirect_to(off_site_requests_url)
    end
  end


  describe "POST create" do
    let(:new_req) { mock_model(OffSiteRequest).as_null_object }
    let(:attrs) { { "created_at" => "2001-12-31 12:12:59Z",
                    "updated_at" => "2001-12-31 12:12:59Z",
                    "hostname" => "asdf.berkeley.edu",
                    "name_of_group" => "group1234",
                    "relationship_of_group" => "relationship1234",
                    "hostname_in_use" =>false,
                    "confirmed_service_qualifications" => false,
                    "for_department_sponsor" => false,
                    "meets_ctc_criteria" => false,
                    "sponsoring_department" => "department1234",
                    "off_site_service" => "service1234",
                    "status" => Status.first.id.to_s } }

    before(:each) do
      current_user.should_receive(:off_site_requests).and_return(mock_req_list)
      mock_req_list.should_receive(:build).with(attrs).and_return(new_req)
    end

    it "sets @os_req to be a newly built off site request from the params" do
      post 'create', :off_site_request => attrs
      assigns[:os_req].should eq(new_req)
    end

    it "sets @os_req attributes to the params"

    it "sets @os_req send_email_notification to true"

    context "when it successfully saves" do
      before(:each) do
        new_req.stub(:save).and_return(true)
      end

      it "gives a message from the flash" do
        post 'create', :off_site_request => attrs
        flash[:notice].should eq("#{new_req.class.to_s} successfully created. Please check your email for further instructions.")
      end

      it "redirects to the edit url of the just made request" do
        post 'create', :off_site_request => attrs
        response.should redirect_to(edit_off_site_request_url(new_req))
      end
    end

    context "when it fails to save" do
      before(:each) do
        new_req.stub(:save).and_return(false)
      end
      it "renders the new template" do
        post 'create', :off_site_request => attrs
        response.should render_template("new")
      end
    end
  end
end