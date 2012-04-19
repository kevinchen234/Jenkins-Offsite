require File.dirname(__FILE__) + '/../spec_helper'

describe LdapSearch do
  
  it "should create filter" do
    LdapSearch.create_filter(:search_by => 'ldap_uid', :search_value => 'uid').should == {:uid=>"uid"}
    LdapSearch.create_filter(:search_by => 'last_first_name', :search_value => 'Last, First').should == {:givenname=>"First", :sn=> "Last"}
    LdapSearch.create_filter(:search_by => 'last_name', :search_value => 'Last').should == { :sn => "Last" }
    LdapSearch.create_filter(:search_by => 'first_name', :search_value => 'first').should == { :givenname => "first" }
    LdapSearch.create_filter(:search_by => 'email', :search_value => 'foo').should == { :mail => 'foo' }
  end

end
