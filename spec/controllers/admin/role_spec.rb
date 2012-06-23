require 'spec_helper'

describe Admin::RolesController do
  fixtures :roles, :users

  let(:user) {mock_model(User)}
  let(:role) {mock_model(Role).as_null_object}
  let(:all_roles){ [mock_model(Role), mock_model(Role)] }


  before(:each) do
    @admin_role = Role.find(ActiveRecord::Fixtures.identify(:admin_role))
    controller.stub(:current_user).and_return(user)
    user.stub(:roles).and_return([@admin_role])
  end

  describe "GET index" do
    it "sets @roles to all roles in the database" do
      Role.should_receive(:all).and_return(all_roles)
      get :index
      assigns[:roles].should eq(all_roles)
    end
  end

  describe "GET new" do
    it "sets @role to a new role" do
      Role.should_receive(:new).and_return(role)
      get :new
      assigns[:role].should eq(role)
    end
  end

  describe "POST create" do

    before(:each) do
      Role.stub(:new).and_return(role)
    end

    it "sets @role to a new role with the params" do
      Role.should_receive(:new).with( {"name" => "test role", "description" => "This is a test role."}).and_return(role)
      post :create, :role => {:name => "test role", :description => "This is a test role."}
      assigns[:role].should eq(role)
    end

    it "tries to save the new role" do
      role.should_receive(:save)
      post :create
    end

    context "when it successfully saves" do
      before(:each) do
        role.stub(:save).and_return(true)
      end
      it "sets the flash notice" do
        post :create
        flash[:notice].should eq("Role successfully created.")
      end

      it "redirects to the admin roles page" do
        post :create
        response.should redirect_to(admin_roles_url)
      end
    end

    context "when it fails to save" do
      before(:each) do
        role.stub(:save).and_return(false)
      end
      it "renders the new template" do
        post :create
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    before (:each) do
      #act as the load_role before filter
      Role.stub(:find).with(@admin_role.id.to_s).and_return(role)
    end
    context "when updating attributes succeeds" do
      before(:each) do
        role.stub(:update_attributes).with({"name" => "New Name", "description" => "Blah Blah Blah."}).and_return(true)
      end

      it "sets the flash notice" do
        put :update, :id => @admin_role.id, :role => {:name => "New Name", :description => "Blah Blah Blah."}
        flash[:notice].should eq "Role successfully updated."
      end

      it "redirects to the admin roles page"  do
        put :update, :id => @admin_role.id, :role => {:name => "New Name", :description => "Blah Blah Blah."}
        response.should redirect_to(admin_roles_url)
      end

    end

    context "when updating attributes fails" do
      before(:each) do
        role.stub(:update_attributes).and_return(false)
      end
      it "renders the edit template" do
        put :update, :id => @admin_role.id, :role => {:name => "New Name", :description => "Blah Blah Blah."}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before (:each) do
      #act as the load_role before filter
      Role.stub(:find).with(@admin_role.id.to_s).and_return(role)
    end

    context "when destroy succeeds" do
      before(:each) do
        role.stub(:destroy).and_return(true)
      end
       it "sets the flash notice"  do
         delete :destroy, :id => @admin_role.id
         flash[:notice].should eq("Role successfully deleted.")
       end
    end

    context "when destroy fails" do
      before(:each) do
        role.stub(:destroy).and_return(false)
      end
      it "sets the flash error" do
        delete :destroy, :id => @admin_role.id
        flash[:error].should eq @admin_role.errors.full_messages {}
      end
    end

    it "redirects to the admin roles page" do
      delete :destroy, :id => @admin_role.id
      response.should redirect_to(admin_roles_url)
    end
  end
end