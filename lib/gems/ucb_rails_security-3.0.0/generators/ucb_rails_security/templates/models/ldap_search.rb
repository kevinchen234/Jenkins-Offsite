require 'ucb_ldap'

class LdapSearch
  SEARCH_TERMS = [ 
    [:last_name_and_first_name, 'Last Name, First Name'],
    [:last_name,                'Last Name'],
    [:first_name,               'First Name'],
    [:email,                    'Email'],
    [:phone,                    'Phone'],
    [:department,               'Department'],
    [:ldap_uid,                 'UID']
  ]

  LDAP_ALIASES = {
    :first_name => :givenname,
    :last_name  => :sn,
    :email      => :mail,
    :phone      => :telephonenumber,
    :department => :berkeleyeduunitcalnetdeptname,
    :ldap_uid   => :uid,
  }
  
  def self.search_term_select_list
    SEARCH_TERMS.collect { |item| [item[1], item[0]] }
  end

  def self.search_arguments_blank?(search_term, search_value)
    search_term.nil? || search_term.empty? || search_value.nil? || search_value.empty?  
  end
  
  def self.find(search_term, search_value)
    return [] if search_arguments_blank?(search_term, search_value)
    
    search_hash = {}
    if search_term.to_sym == SEARCH_TERMS[0][0]
      lname_value, fname_value = search_value.split(",").map { |v| v.strip }
      lname, fname = search_term.split("_and_")
      return [] if lname.nil? || fname.nil?
      search_hash[LDAP_ALIASES[fname.to_sym]] = "#{fname_value}"
      search_hash[LDAP_ALIASES[lname.to_sym]] = "#{lname_value}"
    else
      search_hash[LDAP_ALIASES[search_term.to_sym]] = "#{search_value}"
    end
    
    UCB::LDAP::Person.search(:filter => search_hash)
  end
  
end
