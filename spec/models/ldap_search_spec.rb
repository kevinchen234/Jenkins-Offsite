require File.dirname(__FILE__) + '/../spec_helper'

describe LdapSearch do
  
  it "should create filter" do
    LdapSearch.create_filter(:search_by => 'ldap_uid', :search_value => 'foo').should == {:uid=>"foo"}
    LdapSearch.create_filter(:search_by => 'last_first_name', :search_value => 'bar, foo').should == {:givenname=>"foo", :sn=> "bar"}
    LdapSearch.create_filter(:search_by => 'last_name', :search_value => 'foo').should == { :sn => "foo" }
    LdapSearch.create_filter(:search_by => 'first_name', :search_value => 'foo').should == { :givenname => "foo" }
    LdapSearch.create_filter(:search_by => 'email', :search_value => 'foo').should == { :mail => 'foo' }
  end

end
