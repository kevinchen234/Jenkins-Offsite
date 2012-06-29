require 'spec_helper'

include RspecIntegrationHelpers

describe "AppMonitor interface" do
  it "should return 200 if success" do
    visit_path(check_app_path)
    assert_contain("Ok")
  end
end
