class UcbSecurity::LdapSearchController < UcbSecurity::BaseController

  def index
    @ldap_people = LdapSearch.find(params[:search_term], params[:search_value])
    @select_options = LdapSearch.search_term_select_list()
    @search_term = params[:search_term].blank? ? "" : params[:search_term].to_sym
    @search_initiated = true if params[:commit]
  end

end
