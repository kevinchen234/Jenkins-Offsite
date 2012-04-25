# LDAP Diagnostic Notes

require 'ucb_ldap'
include UCB::LDAP

See some hosts:

    UCB::LDAP::HOST_PRODUCTION
     => "ldap.berkeley.edu"

    UCB::LDAP::HOST_TEST
     => "ldap-test.berkeley.edu"

Set the host to test:

    UCB::LDAP.host=UCB::LDAP::HOST_TEST
     => "ldap-test.berkeley.edu"

Verify:

    UCB::LDAP.host
     => "ldap-test.berkeley.edu"

The gem has a $TESTING flag that exposes private methods:

    private unless $TESTING

    def authentication_information
      ...

If password is nil, the gem uses these defaults:

     def authentication_information
        password.nil? ?
          {:method => :anonymous} :
          {:method => :simple, :username => username, :password => password}
     end

Connect?

    username = "abc"
    password = "def"

    UCB::LDAP.authenticate(username, password)
    -> new_net_ldap

Typical	ports:

    389	is unencrypted
    636	is encrypted

Try it manually:

    require 'net/ldap'
    host = "ldap-test.berkeley.edu"
    authentication_information = {:method => :anonymous}
    port = 636
    encryption = {:method =>:simple_tls}

    @net_ldap = Net::LDAP.new(
          :host => host,
          :auth => authentication_information,
          :port => port,
          :encryption => encryption
          )

    => #<Net::LDAP:0x007fbb29914f38 @host="ldap-test.berkeley.edu",
     @port=636, @verbose=false, @auth={:method=>:anonymous}, @base="dc=com",
     @encryption={:method=>:simple_tls}, @open_connection=nil>

    @net_ldap_connection =
        Net::LDAP::Connection.new(
          :host => host,
          :port => port,
          :encryption => encryption
	)
