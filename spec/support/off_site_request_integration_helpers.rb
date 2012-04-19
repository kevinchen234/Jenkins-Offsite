module OffSiteRequestIntegrationHelpers
  def assert_off_site_request_form_is_readonly(req)
    disabled = ""
    simulate { disabled = "[disabled='disabled']" }
    automate { disabled = ":disabled" }

    pre = "off_site_request"
    assert_have_selector("#{form_id(req)} input[id='#{pre}_submitter_full_name']#{disabled}")
    assert_have_selector("#{form_id(req)} select[id='#{pre}_status_id']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_hostname']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_hostname_in_use_true']#{disabled}")    
    assert_have_selector("#{form_id(req)} input[id='#{pre}_arachne_or_socrates_true']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_sponsoring_department']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_for_department_sponsor_true']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_name_of_group']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_relationship_of_group']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_off_site_ip']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_off_site_service']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_confirmed_service_qualifications_true']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_other_ext_circumstances']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_meets_ctc_criteria_true']#{disabled}")
    assert_have_selector("#{form_id(req)} input[id='#{pre}_campus_official_full_name']#{disabled}")
  end
  
  def fill_out_off_site_request_form
    pre = "off_site_request"
    fill_in("#{pre}_hostname", :with => "unique_hostname.berkeley.edu")
    choose("#{pre}_hostname_in_use_false")
    select("Enterprise Application Service - (JKASD)", :from => "#{pre}_sponsoring_department")
    choose("#{pre}_for_department_sponsor_true")
    fill_in("#{pre}_off_site_service", :with => "Super Service")
    fill_in("#{pre}_off_site_ip", :with => "123.123.123.123")
    choose("#{pre}_confirmed_service_qualifications_true")
    choose("#{pre}_meets_ctc_criteria_true")

    simulate { set_hidden_field("#{pre}_campus_official_ldap_uid", :to => "61065") }
    automate { select_user_from_lightbox("61065", :campus_official) }
  end
  
  def fill_out_admin_off_site_request_form
    fill_out_off_site_request_form
    pre = "off_site_request"
    select("Approved", :from => "#{pre}_status_id")
    fill_in("#{pre}_cns_trk_number", :with => "22")
    fill_in("#{pre}_comment", :with => "A comment")    
    choose("#{pre}_confirmed_by_campus_official_true")
    
    simulate { set_hidden_field("#{pre}_submitter_ldap_uid", :to => "61065") }
    automate { select_user_from_lightbox("61065", :submitter) }    
  end

  def select_user_from_lightbox(ldap_uid, user_type = :user)
    user_type = user_type.to_sym
    if user_type == :submitter
      id  = "off_site_request_submitter_full_name_input"
    elsif user_type == :campus_official
      id  = "off_site_request_campus_official_full_name_input"      
    end
    
    click_link_within("##{id}", "Lookup in LDAP")
    select("Ldap Uid")
    fill_in("ldap_search_search_value", :with => "#{ldap_uid}")
    click_button("Search")
    click_link("#{ldap_uid}")
  end
end
