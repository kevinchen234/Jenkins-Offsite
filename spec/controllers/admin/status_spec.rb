require 'spec_helper'

describe Admin::StatusesController do
  fixtures :statuses, :roles

  let(:user) {mock_model(User)}
  let(:status) {mock_model(Status).as_null_object}
  let(:all_statuses){ [mock_model(Status), mock_model(Status)] }


  before(:each) do
    @admin_role = Role.find(ActiveRecord::Fixtures.identify(:admin_role))
    @approved = Status.find(ActiveRecord::Fixtures.identify(:approved))
    controller.stub(:current_user).and_return(user)
    user.stub(:roles).and_return([@admin_role])
  end

  describe "GET index" do
    it "sets @statuses to all statuses in the database" do
      Status.should_receive(:all).and_return(all_statuses)
      get :index
      assigns[:statuses].should eq(all_statuses)
    end
  end

  describe "GET new" do
    it "sets @status to a new status" do
      Status.should_receive(:new).and_return(status)
      get :new
      assigns[:status].should eq(status)
    end
  end

  describe "POST create" do

    before(:each) do
      Status.stub(:new).and_return(status)
    end

    it "sets @status to a new status with the params" do
      Status.should_receive(:new).with( {"name" => "test status"}).and_return(status)
      post :create, :status => {:name => "test status"}
      assigns[:status].should eq(status)
    end

    it "tries to save the new status" do
      status.should_receive(:save)
      post :create
    end

    context "when it successfully saves" do
      before(:each) do
        status.stub(:save).and_return(true)
      end
      it "sets the flash notice" do
        post :create
        flash[:notice].should eq("Status successfully created.")
      end

      it "redirects to the admin statuses page" do
        post :create
        response.should redirect_to(admin_statuses_url)
      end
    end

    context "when it fails to save" do
      before(:each) do
        status.stub(:save).and_return(false)
      end
      it "renders the new template" do
        post :create
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    before(:each) do
      #act as the load_status before filter
      Status.stub(:find).with(@approved.id.to_s).and_return(status)
    end
    context "when updating attributes succeeds" do
      before(:each) do
        status.stub(:update_attributes).with({"name" => "New Name"}).and_return(true)
      end

      it "sets the flash notice" do
        put :update, :id => @approved.id, :status => {:name => "New Name"}
        flash[:notice].should eq "Status successfully updated."
      end

      it "redirects to the admin statuses page"  do
        put :update, :id => @approved.id, :status => {:name => "New Name"}
        response.should redirect_to(admin_statuses_url)
      end

    end

    context "when updating attributes fails" do
      before(:each) do
        status.stub(:update_attributes).and_return(false)
      end
      it "renders the edit template" do
        put :update, :id => @approved.id, :status => {:name => "New Name"}
        response.should render_template("edit")
      end
    end
  end


end