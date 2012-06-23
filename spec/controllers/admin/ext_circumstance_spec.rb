require 'spec_helper'

describe Admin::ExtCircumstancesController do
  fixtures :ext_circumstances, :users, :roles

  let(:user) {mock_model(User)}
  let(:circumstance) {mock_model(ExtCircumstance).as_null_object}
  let(:all_circumstances){ [mock_model(ExtCircumstance), mock_model(ExtCircumstance)] }


  before(:each) do
    @admin_role = Role.find(ActiveRecord::Fixtures.identify(:admin_role))
    controller.stub(:current_user).and_return(user)
    user.stub(:roles).and_return([@admin_role])
  end

  describe "GET index" do
    it "sets @circumstances to all roles in the database" do
      ExtCircumstance.should_receive(:all).and_return(all_circumstances)
      get :index
      assigns[:circumstances].should eq(all_circumstances)
    end
  end

  describe "GET new" do
    it "sets @circumstance to a new circumstance" do
      ExtCircumstance.should_receive(:new).and_return(circumstance)
      get :new
      assigns[:ext_circumstance].should eq(circumstance)
    end
  end

  describe "POST create" do

    before(:each) do
      ExtCircumstance.stub(:new).and_return(circumstance)
    end

    it "sets @circumstance to a new circumstance with the params" do
      ExtCircumstance.should_receive(:new).with( { "description" => "This is a test circumstance."}).and_return(circumstance)
      post :create, :ext_circumstance => { :description => "This is a test circumstance."}
      assigns[:ext_circumstance].should eq(circumstance)
    end

    it "tries to save the new circumstance" do
      circumstance.should_receive(:save)
      post :create
    end

    context "when it successfully saves" do
      before(:each) do
        circumstance.stub(:save).and_return(true)
      end
      it "sets the flash notice" do
        post :create
        flash[:notice].should eq("ExtCircumstance successfully created.")
      end

      it "redirects to the admin circumstances page" do
        post :create
        response.should redirect_to(admin_ext_circumstances_url)
      end
    end

    context "when it fails to save" do
      before(:each) do
        circumstance.stub(:save).and_return(false)
      end
      it "renders the new template" do
        post :create
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    before (:each) do
      #act as the load_circumstance before filter
      ExtCircumstance.stub(:find).with(@admin_role.id.to_s).and_return(circumstance)
    end
    context "when updating attributes succeeds" do
      before(:each) do
        circumstance.stub(:update_attributes).with({"description" => "Blah Blah Blah."}).and_return(true)
      end

      it "sets the flash notice" do
        put :update, :id => @admin_role.id, :ext_circumstance => {:description => "Blah Blah Blah."}
        flash[:notice].should eq "ExtCircumstance successfully updated."
      end

      it "redirects to the admin circumstances page"  do
        put :update, :id => @admin_role.id, :ext_circumstance => { :description => "Blah Blah Blah."}
        response.should redirect_to(admin_ext_circumstances_url)
      end

    end

    context "when updating attributes fails" do
      before(:each) do
        circumstance.stub(:update_attributes).and_return(false)
      end
      it "renders the edit template" do
        put :update, :id => @admin_role.id, :ext_circumstance => {:description => "Blah Blah Blah."}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before (:each) do
      #act as the load_circumstance before filter
      ExtCircumstance.stub(:find).with(@admin_role.id.to_s).and_return(circumstance)
    end

    context "when destroy succeeds" do
      before(:each) do
        circumstance.stub(:destroy).and_return(true)
      end
      it "sets the flash notice"  do
        delete :destroy, :id => @admin_role.id
        flash[:notice].should eq("ExtCircumstance successfully deleted.")
      end
    end

    context "when destroy fails" do
      before(:each) do
        circumstance.stub(:destroy).and_return(false)
      end
      it "sets the flash error" do
        delete :destroy, :id => @admin_role.id
        flash[:error].should eq ""
      end
    end

    it "redirects to the admin circumstances page" do
      delete :destroy, :id => @admin_role.id
      response.should redirect_to(admin_ext_circumstances_url)
    end
  end
end