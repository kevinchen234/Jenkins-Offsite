require "#{Rails.root}/lib/core_extensions/ldap_person_ext"
UCB::LDAP::Person.include_test_entries = true
UCB::LDAP::Org.build_department_list
