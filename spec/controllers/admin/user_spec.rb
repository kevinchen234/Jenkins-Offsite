require 'spec_helper'

describe Admin::UsersController do

  fixtures :roles, :users

  let(:user) {mock_model(User).as_null_object}
  let(:ldap_person) {UCB::LDAP::Person.new([])}
  let(:all_users) {[mock_model(User), mock_model(User)]}
  let(:user_params){ {"ldap_uid"=>"123",
                      "first_name"=>"I am",
                      "last_name"=>"a test",
                      "email"=>"test@example.edu",
                      "department"=>"Campus Technology Services",
                      "enabled"=>"true",
                      "role_ids"=>["",
                                   "3",
                                   "6"]} }

  before(:each) do
    @admin_role = Role.find(ActiveRecord::Fixtures.identify(:admin_role))
    controller.stub(:current_user).and_return(user)
    controller.stub(:ldap_user).and_return(ldap_person)
    user.stub(:roles).and_return([@admin_role])
    ldap_person.stub(:uid).and_return(11111111)
    User.stub(:find).with("123").and_return(user)
  end

  describe "GET index" do
    it "sets @users to be all users according to filter"  do
      User.should_receive(:find_from_filter).with(nil).and_return(all_users)
      get :index
      assigns[:users].should eq(all_users)
    end

    it "sets @filter_by_options to be the filter options"  do
      User.should_receive(:filter_by_options).and_return(["Select One", "buyers", "admins", "disabled"])
      get :index
      assigns[:filter_by_options].should eq(["Select One", "buyers", "admins", "disabled"])
    end
  end

  describe "GET new" do
    it "sets @user to be a new user made from the current user's ldap uid" do
      User.should_receive(:new_from_ldap_uid).with(ldap_person.uid).and_return(user)
      get :new
      assigns[:user].should eq(user)
    end
  end

  describe "POST create" do
    before(:each) do
      User.stub(:new_from_attr_hash).and_return(user)
    end

    it "makes a new user from the params and then tries to save it" do
      User.should_receive(:new_from_attr_hash).with({"first_name" => "I am", "last_name" => "a test"}).and_return(user)
      user.should_receive(:save!)
      post :create, :user => {"first_name" => "I am", "last_name" => "a test"}
      assigns[:user].should eq(user)
    end

    context "when saving succeeds" do
      before(:each) do
        user.stub(:save!).and_return(true)
      end

      it "sets the flash notice" do
        post :create
        flash[:notice].should eq("User successfully created.")
      end

      it "redirects to the admin editing page for the new user" do
        post :create
        response.should redirect_to(edit_admin_user_url(user))
      end
    end

    context "when saving fails" do
      before(:each) do
        user.stub(:save!).and_raise(ActiveRecord::RecordInvalid.new(user))
      end

      it "renders the new template" do
        post :create
        response.should render_template("new")
      end
    end
  end

  describe "Put update" do
    context "when update_attributes succeeds" do
      before(:each) do
        user.stub(:update_attributes!).and_return(true)
      end

      it "sets the flash notice" do
        put :update, :id => 123, :user => user_params
        flash[:notice].should eq("User successfully updated.")
      end

      it "redirects to the admin edit page for the current user" do
        put :update, :id => 123, :user => user_params
        response.should redirect_to(edit_admin_user_url(user))
      end
    end

    context "when update_attributes fails" do
      before(:each) do
        user.stub(:update_attributes!).and_raise(ActiveRecord::RecordInvalid.new(user))
      end

      it "renders the edit template" do
        put :update, :id => 123, :user => user_params
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    context "when destroy succeeds" do
      before(:each) do
        user.stub(:destroy).and_return(true)
      end
      it "sets the flash notice" do
        delete :destroy, :id => 123
        flash[:notice].should eq("User successfully deleted.")
      end

      it "redirects to the admin users url" do
        delete :destroy, :id => 123
        response.should redirect_to(admin_users_url)
      end
    end

    context "when destroy fails" do
      before(:each) do
        user.stub(:destroy).and_return(false)
      end
      it "sets the flash error" do
        delete :destroy, :id => 123
        flash[:error].should eq("")
      end

      it "redirects to the admin edit page for the current user" do
        delete :destroy, :id => 123
        response.should redirect_to(edit_admin_user_url(user))
      end
    end
  end

  describe "GET login" do
    it "calls application_login on the selected user" do
      user.stub(:ldap_uid).and_return(123)
      controller.should_receive(:application_login).with(123)
      get :login, :id => 123
    end

    it "redirects to the root url" do
      get :login, :id => 123
      response.should redirect_to(root_url)
    end
  end
end