namespace :ucb do
  desc 'Create user w/security role'
  task :create_security_user => :environment do
    if (ldap_uid = ENV['UID'])
      role = Role.find_or_create_by_name('security')
      begin
        user = User.find_or_create_by_ldap_uid!(ldap_uid)
        user.roles << role unless user.roles.include?(role)
        user.save!
        puts "Security role granted to user (ldap_uid: #{ldap_uid})"
      rescue UCB::LDAP::Person::RecordNotFound
        puts "Unable to find person (ldap_uid: #{ldap_uid}) in LDAP."
      end
    else
      puts
      puts 'USAGE: '
      puts "\trake ucb:create_security_user UID=<uid>"
      puts "\trake ucb:create_security_user UID=<uid> Rails.env=<env>"
      puts
    end
  end
end