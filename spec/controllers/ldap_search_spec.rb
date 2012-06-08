require 'spec_helper'

describe LdapSearchController do
  fixtures :all
  describe "GET index" do

    it "sets @select_options" do

      LdapSearch.should_receive(:search_by_options).and_return( [['Last Name', 'last_name'],
                                                                 ['Last Name, First Name', 'last_first_name'],
                                                                 ['First Name', 'first_name'],
                                                                 ['Ldap Uid', 'ldap_uid'],
                                                                 ['Email', 'email']])
      get 'index'
      assigns[:select_options].should eq([['Last Name', 'last_name'],
                                          ['Last Name, First Name', 'last_first_name'],
                                          ['First Name', 'first_name'],
                                          ['Ldap Uid', 'ldap_uid'],
                                          ['Email', 'email']])
    end

    #LdapSearch doesn't extend ActiveModel::Naming so we can't make a mock_model of it
    #not sure if stub_model is okay
    it "sets @ldap_search" do
      search = stub_model(LdapSearch)
      LdapSearch.should_receive(:new).with("search_for" => "campus_official").and_return(search)

      get 'index', :ldap_search => { :search_for => "campus_official" }
      assigns[:ldap_search].should eq(search)
    end

    it "logs something"

    it "renders the index template" do
      get 'index'
      response.should render_template("index")
    end
  end

  describe "GET do_search" do

    it "sets @select_options" do
      LdapSearch.should_receive(:search_by_options).and_return( [['Last Name', 'last_name'],
                                                                 ['Last Name, First Name', 'last_first_name'],
                                                                 ['First Name', 'first_name'],
                                                                 ['Ldap Uid', 'ldap_uid'],
                                                                 ['Email', 'email']])
      get 'index'
      assigns[:select_options].should eq([['Last Name', 'last_name'],
                                          ['Last Name, First Name', 'last_first_name'],
                                          ['First Name', 'first_name'],
                                          ['Ldap Uid', 'ldap_uid'],
                                          ['Email', 'email']])
    end

    it "sets @ldap_search" do
      search = stub_model(LdapSearch)
      LdapSearch.should_receive(:new).with("search_for" => "campus_official").and_return(search)

      get 'index', :ldap_search => { :search_for => "campus_official" }
      assigns[:ldap_search].should eq(search)
    end

    it "sets @users" do
      search = stub_model(LdapSearch)
      LdapSearch.should_receive(:new).with("search_for" => "campus_official").and_return(search)
      search.should_receive(:find).and_return([User.find_by_uid(0101010)])

      get 'do_search', :ldap_search => { :search_for => "campus_official" }
      assigns[:users].should eq([User.find_by_uid(0101010)])
    end

    it "sets @callback" do
      search = stub_model(LdapSearch)
      LdapSearch.should_receive(:new).with("search_for" => "campus_official").and_return(search)
      search.should_receive(:find).and_return([User.find_by_uid(0101010)])
      search.should_receive(:search_for).twice.and_return("campus_official")
      controller.should_receive(:callback).with("campus_official").and_return("observe_and_update_campus_official")

      get 'do_search', :ldap_search => { :search_for => "campus_official" }
      assigns[:callback].should eq("observe_and_update_campus_official")

    end

    #not sure why I need to go through all the methods for the render_template to work
    it "renders the index template" do
      search = stub_model(LdapSearch)
      LdapSearch.stub(:new).with("search_for" => "campus_official").and_return(search)
      search.stub(:find).and_return([User.find_by_uid(0101010)])
      search.stub(:search_for).twice.and_return("campus_official")
      controller.stub(:callback).with("campus_official").and_return("observe_and_update_campus_official")

      get 'do_search', :ldap_search => {:search_for => "campus_official"}

      response.should render_template("index")
    end
  end

end