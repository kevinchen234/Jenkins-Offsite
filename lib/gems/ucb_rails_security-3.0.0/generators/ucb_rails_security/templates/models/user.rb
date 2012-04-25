class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => 'user_roles', :order => 'name'
  
  validates_uniqueness_of :ldap_uid
  validates_uniqueness_of :email, :unless => lambda { |user| user.email.blank? }
  validates_presence_of :ldap_uid, :first_name, :last_name
  
  def formatted_created_at()
    created_at.strftime('%m-%d-%Y')
  end

  def current_user?(ldap_uid)
    self.ldap_uid == ldap_uid
  end

  def full_name()
    "#{first_name} #{last_name}"
  end

  def display_name()
    "#{last_name}, #{first_name}"
  end

  def sync_attributes_with_ldap!()
    ldap_person = UCB::LDAP::Person.find_by_uid(self.ldap_uid)
    raise UCB::LDAP::Person::RecordNotFound if ldap_person.nil?
    self.update_attributes!(self.class.attributes_hash_for_ldap_person(ldap_person))
  end
  
  class << self
    ### Start Class Aliases ###
    #
    # These methods provide aliases for ActiveRecord's
    # dynamic finders and can't be aliased with the
    # usual: alias :new_method :old_method
    #
    def find_by_uid(ldap_uid)
      find_by_ldap_uid(ldap_uid)
    end

    def new_from_uid(ldap_uid)
      new_from_ldap_uid(ldap_uid)
    end
    ### End Class Aliases ####
    
    def find_or_create_by_ldap_uid!(ldap_uid)
      user = find_or_create_by_ldap_uid(ldap_uid)
      if user.new_record?
        ldap_person = UCB::LDAP::Person.find_by_uid(ldap_uid)
        raise UCB::LDAP::Person::RecordNotFound if ldap_person.nil?
        user.attributes = attributes_hash_for_ldap_person(ldap_person)
        user.save!
      end
      user
    end
    
    def new_from_ldap_uid(ldap_uid)
      ldap_person = ldap_uid.nil? ? nil : UCB::LDAP::Person.find_by_uid(ldap_uid)
      if ldap_person.nil?
        self.new
      else
        user = self.new
        user.attributes = attributes_hash_for_ldap_person(ldap_person)
        user
      end
    end

    def attributes_hash_for_ldap_person(ldap_person)
      {
        :ldap_uid => ldap_person.uid,
        :first_name => ldap_person.first_name,
        :last_name => ldap_person.last_name,
        :phone => ldap_person.phone,
        :email => ldap_person.email,
        :department => ldap_person.dept_name
      }
    end
    
    def find_in_ldap(search_params = {})
      return [] if search_params.empty?

      ldap_people = []
      UCB::LDAP::Person.search(:filter => search_params).each do |person|
        ldap_people << person
      end
      ldap_people
    end
    
    def sync_all_with_ldap!()
      unfound = []
      users = self.find(:all).each do |u|
         begin
          u.sync_attributes_with_ldap!
        rescue UCB::LDAP::Person::RecordNotFound => e
          unfound << u.uid
        end
      end

      unless unfound.blank?
        msg = "Sync failed for uids: #{unfound.join(',')}"
        raise(UCB::LDAP::Person::RecordNotFound, msg)
      end
    end
  end
  
end
