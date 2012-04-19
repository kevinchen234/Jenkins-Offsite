
module RspecIntegrationHelpers
  ##
  # Add wrapper around visit(url) as a work around for this problem
  # https://webrat.lighthouseapp.com/projects/10503/tickets/226-not-waiting-for-page-load-with-selenium
  #
  def visit_path(path)
    visit(path)
    automate { selenium.wait_for_page_to_load(6) }    
  end
  
  def login_user(_obj)
    ldap_uid = _obj.is_a?(User) ? _obj.ldap_uid : _obj
    visit_path(login_path(:test_auth_ldap_uid => ldap_uid))
  end

  def logout_current_user
    visit_path(logout_path)
  end
  
  def dom_id(*args)
    App.dom_id(*args)
  end

  def should_require_attr(obj, attr, errs = 1)
    obj.send("#{attr}=", nil)
    obj.send(:should_not, be_valid)
    obj.send(:should, have(errs).error_on(attr))
  end

  def row_sel(model)
    id = model.class.name.underscore
    "##{id}_list tr##{dom_id(model)}"
  end
  
  def form_id(model)
    name = model.class.name.underscore
    model.new_record? ? "form#new_#{name}" : "form#edit_#{dom_id(model)}"
  end
  
  def perform_ldap_search_for(_user)
    select("Ldap Uid", :from => "ldap_search_search_by")
    fill_in("ldap_search_search_value", :with => _user.ldap_uid)
    click_button("Search")
    sleep(1)
    assert_have_selector("table#user_search_results")    
  end

  def select_ldap_search_result(_user)
    click_link_within("table#user_search_results tr##{_user.ldap_uid.to_s}", _user.ldap_uid.to_s)
  end

  def stub_department_list
    depts = [["ARCH Computing - (DBCOM)", "ARCH Computing - (DBCOM)"],
             ["Application Services - (JKASD)", "Application Services - (JKASD)"]]
    UCB::LDAP::Org.stub!(:build_department_list).and_return(depts)
  end
end
