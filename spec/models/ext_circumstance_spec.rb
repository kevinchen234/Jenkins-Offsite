require 'spec_helper'

describe ExtCircumstance, "referential integrity" do
  fixtures :off_site_requests, :ext_circumstances
  before(:each) do
    @ext_cir = ext_circumstances(:ext_one)
    @req = off_site_requests(:runner_request_1)
  end

  it "should not be destroyed if it is referenced by other records" do
    @ext_cir.off_site_requests.should have(2).records
    @ext_cir.destroy.should be_false

    @ext_cir.off_site_requests.clear
    @ext_cir.save!
    @ext_cir.off_site_requests.should be_empty
    @ext_cir.destroy.should be_true
  end

end

