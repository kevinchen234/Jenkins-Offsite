require 'spec_helper'

describe Admin::OffSiteRequestsController do

  fixtures :roles, :off_site_requests

  let(:user) {mock_model(User)}
  let(:os_req) {mock_model(OffSiteRequest).as_null_object}
  let(:all_requests) {[mock_model(OffSiteRequest), mock_model(OffSiteRequest)]}
  let(:attrs) { { "created_at" => "2001-12-31 12:12:59Z",
                  "updated_at" => "2001-12-31 12:12:59Z",
                  "hostname" => "asdf.berkeley.edu",
                  "hostname_in_use" => nil,
                  "off_site_ip" => nil,
                  "ext_circumstance_ids" => nil,
                  "other_ext_circumstances" => nil,
                  "campus_official_ldap_uid" => "123",
                  "name_of_group" => "group1234",
                  "relationship_of_group" => "relationship1234",
                  "hostname_in_use" =>false,
                  "confirmed_service_qualifications" => false,
                  "for_department_sponsor" => false,
                  "sponsoring_department" => "department1234",
                  "off_site_service" => "service1234",
                  "additional_DNS_instructions" => nil,
                  "status" => Status.first.id.to_s } }


  before(:each) do
    @admin_role = Role.find(ActiveRecord::Fixtures.identify(:admin_role))
    @sample_req = OffSiteRequest.find(ActiveRecord::Fixtures.identify(:minimal_for_validation))
    controller.stub(:current_user).and_return(user)
    user.stub(:roles).and_return([@admin_role])
    OffSiteRequest.stub(:find).with(@sample_req.id.to_s).and_return(os_req)
  end

  describe "GET index" do
    it "sets @os_reqs to be all Off Site Requests"  do
      OffSiteRequest.should_receive(:sortable_find_all)
      .with({"action"=>"index", "controller"=>"admin/off_site_requests"})
      .and_return(all_requests)

      get :index
      assigns[:os_reqs].should eq(all_requests)
    end

    it "renders the index template" do
      get :index
      response.should render_template("index")
    end
  end

  describe "GET new" do
    it "sets @os_req to a new Off Site Request" do
      OffSiteRequest.should_receive(:new).and_return(os_req)
      get:new
      assigns[:os_req].should eq(os_req)
    end
  end

  describe "POST create" do
    before(:each) do
      OffSiteRequest.stub(:new).with(Hash[Array(attrs)[2..-2]]).and_return(os_req)
      #Don't expect protected attributes in call to new as those are assigned separately

      #os_req.stub(:protected_attributes=).with(attrs).and_return(os_req)
    end

    context "when enforcing validations is off" do
      before(:each) do
        os_req.stub(:enforce_validation?).and_return(false)
      end
      it "calls save_with_validations(false)" do
        os_req.should_receive(:save).with(:validate => false)
        post :create, :off_site_request => attrs
      end

      it "sets the flash notice"  do
        post :create, :off_site_request => attrs
        flash[:notice].should eq("OffSiteRequest successfully created.")
      end

      it "redirects to the editing page of the new request" do
        post :create, :off_site_request => attrs
        response.should redirect_to(edit_admin_off_site_request_url(os_req))
      end
    end

    context "when enforcing validations is on" do
      before(:each) do
        os_req.stub(:enforce_validation?).and_return(true)
      end
      context "when saving the new request succeeds" do
        before(:each) do
          os_req.stub(:save).and_return(true)
        end
        it "sets the flash notice" do
          post :create, :off_site_request => attrs
          flash[:notice].should eq("OffSiteRequest successfully created.")
        end

        it "redirects to the editing page of the new request" do
          post :create, :off_site_request => attrs
          response.should redirect_to(edit_admin_off_site_request_url(os_req))
        end
      end

      context "when saving the new request fails" do
        before(:each) do
          os_req.stub(:save).and_return(false)
        end
        it "renders the new template" do
          post :create, :off_site_request => attrs
          response.should render_template("new")
        end
      end
    end
  end

  describe "PUT update" do

    context "when enforcing validations is off" do
      before(:each) do
        os_req.stub(:enforce_validation?).and_return(false)
      end
      it "calls save_with_validations(false)" do
        os_req.should_receive(:save).with(:validate => false)
        put :update, :off_site_request => attrs, :id => @sample_req.id
      end

      it "sets the flash notice"  do
        put :update, :off_site_request => attrs, :id => @sample_req.id
        flash[:notice].should eq("OffSiteRequest successfully updated.")
      end

      it "redirects to the editing page of the new request" do
        put :update, :off_site_request => attrs, :id => @sample_req.id
        response.should redirect_to(edit_admin_off_site_request_url(os_req))
      end
    end

    context "when enforcing validations is on" do
      before(:each) do
        os_req.stub(:enforce_validation?).and_return(true)
      end
      context "when saving the new request succeeds" do
        before(:each) do
          os_req.stub(:save).and_return(true)
        end
        it "sets the flash notice" do
          put :update, :off_site_request => attrs, :id => @sample_req.id
          flash[:notice].should eq("OffSiteRequest successfully updated.")
        end

        it "redirects to the editing page of the new request" do
          put :update, :off_site_request => attrs, :id => @sample_req.id
          response.should redirect_to(edit_admin_off_site_request_url(os_req))
        end
      end

      context "when saving the new request fails" do
        before(:each) do
          os_req.stub(:save).and_return(false)
        end
        it "renders the edit template" do
          put :update, :off_site_request => attrs, :id => @sample_req.id
          response.should render_template("edit")
        end
      end
    end
  end

  describe "DELETE destroy" do
    context "when destroy succeeds" do
      before(:each) do
        os_req.stub(:destroy).and_return(true)
      end
      it "sets the flash notice" do
        delete :destroy, :id => @sample_req.id
        flash[:notice].should eq("OffSiteRequest successfully deleted.")
      end

      it "redirects to the admin Off Site Requests page" do
        delete :destroy, :id => @sample_req.id
        response.should redirect_to(admin_off_site_requests_url)
      end
    end

    context "when destroy fails" do
      before(:each) do
        os_req.stub(:destroy).and_return(false)
      end
      it "sets the flash error" do
        delete :destroy, :id => @sample_req.id
        flash[:error].should eq []
      end

      it "redirects to the edit page of the Off Site Request"  do
        delete :destroy, :id => @sample_req.id
        response.should redirect_to(edit_admin_off_site_request_url(os_req))
      end
    end
  end
end