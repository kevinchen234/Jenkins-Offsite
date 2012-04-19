module UserIntegrationHelpers
  def user_form_id(user)
    user.new_record? ? "form#new_user" : "form#edit_#{dom_id(user)}"
  end

  def check_role(role)
    check("user_role_ids_#{role.id.to_s}")
  end
  
  def verify_role_not_checked(role)
    rid = role.id.to_s
    css_sel = "input[id=user_role_ids_#{rid}][type='checkbox'][value='#{rid}'][checked='checked']"
    assert_have_no_selector(css_sel)
  end
  
  def verify_role_checked(role)
    rid = role.id.to_s    
    css_sel = "input[id=user_role_ids_#{rid}][type='checkbox'][value='#{rid}'][checked='checked']"
    assert_have_selector(css_sel)
  end
  
  def verify_new_user_form(user)
    verify_user_form(user, user_form_id(user))
  end
  
  def verify_edit_user_form(user)
    verify_user_form(user, user_form_id(user))
  end
  
  def verify_user_form(user, form_id)
    assert_have_selector(form_id)

    [:first_name, :last_name, :ldap_uid, :email, :department].each do |att|    
      assert_have_selector("#{form_id} input[id=user_#{att}][value='#{user.send(att).to_s}']")
    end
    
    # check enabled radio button
    if user.enabled?
      assert_have_selector("#{form_id} input[id=user_enabled_true][type='radio'][value=true][checked='checked']")
    else
      assert_have_selector("#{form_id} input[id=user_enabled_false][type='radio'][value=false][checked='checked']")
    end
    
    user.roles.each { |r| verify_role_checked(r) }
    (user.roles - Role.all()).each { |r| verify_role_not_checked(r) }
  end
end
