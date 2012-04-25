require "#{File.dirname(__FILE__)}/_setup.rb"

describe "Filter user" do

  context "The user filter" do
    before(:each) do
      @controller = new_controller()
      UCB::Rails::Security.using_user_table = true
    end

    specify "should call filter_logged_in when user not logged in" do
      @controller.should_receive(:filter_logged_in).and_return(false)
      @controller.filter_user_foo.should be_false
    end

    specify "should call filter_in_user_table() when user logged in" do
      @controller.stub!(:filter_logged_in).and_return(true)
      @controller.should_receive(:filter_in_user_table).and_return(false)
      @controller.stub!(:redirect_to)
      @controller.stub!(:not_authorized_url).and_return("nal")
      @controller.filter_user_foo.should be_false
    end
  end

  context "For a logged in user in the user table" do
    before(:each) do
      @controller = new_controller()
      @user = mock("user")
      @controller.stub!(:filter_logged_in).and_return(true)
      @controller.stub!(:filter_in_user_table).and_return(true)
      @controller.stub!(:user_table_user).and_return(@user)
      @controller.stub!(:redirect_to)
      @controller.stub!(:not_authorized_url).and_return("nal")
    end

    specify "filter_user_method returns 'true' if user.method does" do
      @user.stub!(:true_method).and_return(true)
      @controller.filter_user_true_method.should be_true
    end

    specify "filter_user_method returns 'false' if user.method does" do
      @user.stub!(:false_method).and_return(false)
      @controller.filter_user_false_method.should be_false
    end

    specify "filter_user_column__eq__value returns 'true' if column == 'value'" do
      @user.stub!(:column).and_return("a")
      @controller.filter_user_column__eq__a.should be_true
      @controller.filter_user_column__eq__b.should be_false
    end

    specify "filter_user_column__ne__value returns 'true' if column != 'value'" do
      @user.stub!(:column).and_return("a")
      @controller.filter_user_column__ne__a.should be_false
      @controller.filter_user_column__ne__b.should be_true
    end
  end

end
