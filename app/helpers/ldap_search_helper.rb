module LdapSearchHelper
  
  def eligibility_header(search_for)
    "Eligible #{search_for.titleize}?"
  end

  def eligible?(search_for, user)
    case search_for.to_sym
    when :user
      user.eligible_user?
    when :campus_official
      user.eligible_campus_official?
    when :submitter
      user.eligible_submitter?
    end
  end
  

  ##
  # returns "ineligible_row" if argument is false
  # returns nil if argument is true
  #
  def ineligible_css(user_eligibility_bool)
    "ineligible_row" unless user_eligibility_bool
  end
  
  def ldap_uid_link_or_text(search_for, user)
    if eligible?(search_for, user)
      link_to(user.ldap_uid, ldap_person_query_string(user))
    else
      user.ldap_uid.to_s
    end
  end
end
