class LdapSearchController < ApplicationController
  
  def index
    @select_options = LdapSearch.search_by_options()
    @ldap_search = LdapSearch.new(params[:ldap_search])
    Rails.logger.debug("Search For: #{@ldap_search.search_for()}")    
    respond_to do |format|
      format.html { render("index") }
      format.js { render("index", :layout => false) }
    end
  end
  
  def do_search
    @select_options = LdapSearch.search_by_options()
    @ldap_search = LdapSearch.new(params[:ldap_search])
    Rails.logger.debug("Search For: #{@ldap_search.search_for()}")
    @users = @ldap_search.find()
    @callback = callback(@ldap_search.search_for())
    Rails.logger.debug("Callback: #{@callback}")
    respond_to do |format|
      format.html { render("index") }
      format.js { render("do_search.rjs") }
    end
  end
  
  
  protected
  
  def callback(_key)
    if _key == "user"
      "observe_and_update_user"
    elsif _key == "campus_official"
      "observe_and_update_campus_official"
    elsif _key == "submitter"
      "observe_and_update_submitter"
    end
  end
end
