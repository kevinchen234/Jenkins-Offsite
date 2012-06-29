require 'spec_helper'

describe UsersController do

  let(:mock_ldap_person) { UCB::LDAP::Person.new([]) }
  before(:each) do
    user.ldap_uid=78392
    User.stub(:new).and_return(user)
    mock_ldap_person.stub(:uid).and_return(user.ldap_uid)
    #session[:ldap_user] = mock_ldap_person
    controller.stub(:ldap_user).and_return(mock_ldap_person)
    controller.stub(:ensure_authenticated_user).and_return(true)
  end

  describe "GET new" do

    let(:user) { stub_model(User)}

    it "assigns a new user to @user with their uid" do
      User.should_receive(:new_from_ldap_uid).and_return(user)
      get 'new'
      assigns[:user].should eq(user)
      assigns[:user].ldap_uid.should eq(mock_ldap_person.uid)
    end
  end

  describe "POST create" do

    #This test goes through the whole action and checks values of some methods so it needs
    #user to be a stub_model so I put it in a separate context
    context "when going through the whole action" do
      let(:user) { stub_model(User) }

      it "creates a new user and sets the uid and enabled" do
        User.should_receive(:new).with("first_name" => "Nathan", "last_name" => "Connor").and_return(user)
        post :create, :user => { :first_name => "Nathan", :last_name => "Connor"}

        #Need to check that UID and enabled are correct
        assigns[:user].ldap_uid.should equal(mock_ldap_person.uid)
        assigns[:user].enabled.should equal(true)
      end
    end

    #These tests need user to be a mock_model that is a null object so it doesn't
    #respond to methods so I put them in a separate context
    context "when going through parts of the action" do

      let(:user) { mock_model(User).as_null_object }

      it "assigns @user" do
        user.stub(:save).and_return(false)

        post :create
        assigns[:user].should equal(user)
      end



      it "tries to save the new user" do

        user.should_receive(:save)

        post :create
      end

      context "when the user is successfully saved" do
        before do
          user.stub(:save).and_return(true)
        end

        it "sets a flash[:notice] message" do
          post :create
          flash[:notice].should eq("Your information was successfully updated.")
        end


        context "when app login succeeds" do
          it "redirects to the requests url" do
            controller.stub(:application_login).and_return(true)
            post :create
            response.should redirect_to(off_site_requests_url)
          end
        end
        context "when app login fails" do
          it "redirects to a not authorized page" do
            controller.stub(:application_login).and_return(false)
            post :create
            response.should redirect_to(not_authorized_url)
          end
        end
      end

      context "when the user fails to save" do
        before(:each) do
          user.stub(:save).and_return(false)
        end
        it "should re-render the new template" do
          post :create
          response.should render_template("new")
        end

        it "should have an empty flash[:notice] message" do
          post :create
          flash[:notice].should be_nil
        end
      end
    end
  end
end