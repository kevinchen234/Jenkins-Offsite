
module UCB
  module Rails
    module Security
      module RspecHelpers
        #
        # Adds mock user login functionality for testing apps using ucb_rails_security
        #
        # The main advantage to using these helpers is that, when running your tests,
        # actual ldap connections are never made, instead a mock ldap object is used.
        # This dramatically increases the performance of your tests.
        #
        # The helpers also avoid adding the logged in user to the users table, again
        # this increases the speed of the tests.
        #
        #
        # Usage:
        #
        #  # log user into the application before controller test(s) are run.
        #  before(:each) do
        #    login_user() do
        #      User.create!(
        #        :ldap_uid => "666", 
        #        :first_name => "first_name", 
        #        :last_name => "last_name"
        #      )
        #    end
        #  end
        #
        #
        #  # log user into the application with specified roles before controller 
        #  # test(s) are run.
        #  before(:each) do
        #    login_user_with_roles(["security", "admin"]) do
        #      User.create!(
        #        :ldap_uid => "666", 
        #        :first_name => "first_name", 
        #        :last_name => "last_name"
        #      )
        #    end
        #  end
        #
        # One caveat, when using login_user_with_roles, the roles that are granted 
        # to the user are not saved to the database.  For that user, we stub 
        # user.roles to return those roles.  This means that you cannot add additional
        # roles to this user during a test as roles() has been stubbed. The user
        # you use to login should only be used to allow access to a given 
        # controller/action during your test.
        
        def mock_ldap_person(ldap_uid = 1)
          ldap_person = mock("ldap_person")
          ldap_person.stub!(:uid).and_return(ldap_uid.to_s)
          ldap_person.stub!(:email).and_return("email_#{ldap_uid}")
          ldap_person.stub!(:first_name).and_return("first_name_#{ldap_uid}")
          ldap_person.stub!(:last_name).and_return("last_name_#{ldap_uid}")
          ldap_person.stub!(:phone).and_return("phone_#{ldap_uid}")
          ldap_person.stub!(:dept_code).and_return("dept_code_#{ldap_uid}")
          ldap_person.stub!(:dept_name).and_return("dept_name_#{ldap_uid}")
          ldap_person
        end

        def new_user_instance(ldap_uid = 1)
          User.new(
            :ldap_uid => ldap_uid,
            :email => "email_#{ldap_uid}",
            :first_name => "first_name_#{ldap_uid}",
            :last_name => "last_name_#{ldap_uid}",
            :phone => "phone_#{ldap_uid}",
            :department => "department_#{ldap_uid}"
          )
        end

        # Logs in a given user with the specified roles.  Block should return the User instance:
        #
        # @current_user = login_user_with_roles(["security"]) do
        #   User.create!(:ldap_uid => "666", :first_name => "first_name", :last_name => "last_name") 
        # end
        #
        def login_user_with_roles(roles, &block)
          raise(Exception, "Expecting block to return User object") unless block_given?
          user = yield()
          login_user(user)
          grant_roles_to_user(user, roles)
          user
        end

        # Logs in a given user to the application:
        #
        #   user = User.create!(:ldap_uid => "666", :first_name => "first_name", :last_name => "last_name") 
        #   login_user(user)
        #
        def login_user(user, &block)
          user = yield() if block_given?
          raise(Exception, "login_user() expects user object as argument or return value of a block") if user.nil?
          UCB::Rails::Security::CASAuthentication.force_login_filter_true_for = user.ldap_uid
          mock_ldap_person = UCB::LDAP::Person.new([])
          mock_ldap_person.stub!(:first_name).and_return(user.first_name)
          mock_ldap_person.stub!(:last_name).and_return(user.last_name)
          mock_ldap_person.stub!(:uid).and_return(user.ldap_uid)
          
          # Inject our mock objects into the UCB::Rails::Security system
          controller().send(:ldap_user=, mock_ldap_person)
          controller().send(:user_table_id=, user.id)
          controller().send(:user_table_user=, user)
          user
        end

        # Gives the uesrs instance the specified roles:
        #
        #   grant_roles_to_user(user, ["Security"])
        #
        def grant_roles_to_user(user, r_names)
          roles = r_names.map { |r| Role.new(:name => r) }
          user.stub!(:roles).and_return(roles)
          user
        end
        
      end
    end
  end
end
