require 'spec_helper'


describe "#destroy has referential integrity" do
  fixtures :off_site_requests, :ext_circumstances

  it "should not allow ext circumstances to be deleted if referenced by other records" do
    ext_cir = ext_circumstances(:ext_one)
    osr = off_site_requests(:minimal_for_validation)
    ext_cir.off_site_requests << osr
    ext_cir.save!
    ext_cir.off_site_requests.should have(1).records
    lambda {ext_cir.destroy}.should raise_error DestroyWithReferencesError
  end

  it "should allow an ext circumstance to be deleted if it is not referenced by other records" do
    ext_cir = ext_circumstances(:ext_one)
    ext_cir.off_site_requests.clear
    ext_cir.save!
    ext_cir.off_site_requests.should be_empty
    ext_cir.destroy.should be_true
  end



end


