class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => "user_roles"
  has_many :off_site_requests, :foreign_key => "submitter_id"

  attr_accessible :first_name, :last_name, :email, :email_confirmation, :department, :phone
  attr_accessor :ldap_person

  validates_presence_of :ldap_uid, :first_name, :last_name, :email, :enabled
  validates_inclusion_of :enabled, :in => [true, false]
  validates_confirmation_of :email, :message => "should match confirmation"
  validates_uniqueness_of :ldap_uid
  validates_uniqueness_of :email, :unless => lambda { |r| r.email.blank? }
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                      :unless => lambda { |r| r.email.blank? }


  scope :enabled, :conditions => {:enabled => true}
  scope :disabled, :conditions => {:enabled => false}
  scope :campus_buyers, joins(:roles).where("roles.name = '#{Role::BUYER}'")
  scope :admins, joins(:roles).where("roles.name = '#{Role::ADMIN}'")

  ##
  # Make sure we can't delete this record if other records depend on it.
  #
  def before_destroy
    if !off_site_requests.empty?
      errors.add_to_base("Unable to delete:  record is referenced by #{off_site_requests.length} Off-site Request records")
      false
    end
  end

  def protected_attributes=(params = {})
    if !params.is_a?(::HashWithIndifferentAccess)
      params = ::HashWithIndifferentAccess.new.merge(params)
    end

    #TODO: refac to remove this -- ideally this method will only assign protected attrs.
    #
    # The old code:
    #    self.attributes = params
    #
    # We don't want to assign mass-assignable params here because it's mixing purposes.
    # So during the upgrade to Rails 2.3, we will check for any unexpected input,
    # and raise a warning; this will give us some detection during the upgrade.
    # After the upgrade, please remove this entire block.
    unknown_params = params.reject { |key, value| ["enabled", "ldap_uid", "role_ids"].include?(key) }
    if !unknown_params.empty? then
      raise "Deprecated #{params}"
    end
    ###

    self.enabled = params[:enabled]
    self.ldap_uid = params[:ldap_uid]

    #TODO: remove role_ids from this method because it's not really an attribute, it's an association
    #
    # The old code:
    #    self.role_ids = params[:role_ids]
    #
    # We don't want to assign association ids here because it's mixing purposes.
    # So during the upgrade to Rails 2.3, we will check for any use of the old code
    # and raise a warning; this will give us some detection during the upgrade.
    # After the upgrade, please remove this entire block.
    if params[:role_ids] then
      raise "Deprecated"
    end
    ###

  end

  def to_s
    full_name
  end

  def formatted_created_at
    created_at.strftime('%m-%d-%Y')
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    "#{last_name}, #{first_name}"
  end

  def self.select_list
    items = self.all(:order => 'last_name, first_name').map { |u| [u.display_name, u.id] }
    items.unshift(["Select One", ""])
  end

  ##
  # Formtastic has a bug where :prompt => "Select One" doesn't work
  # when a record is being edit.  So, we add it manually here
  #
  def self.campus_buyers_select_list
    items = self.campus_buyers.map { |u| [u.full_name, u.id] }
    items.unshift(["Select One", ""])
  end

  def current_user?(ldap_obj)
    if ldap_obj.is_a?(String) || ldap_obj.is_a?(Integer)
      self.ldap_uid == ldap_obj.to_i
    else
      self.ldap_uid == ldap_obj.ldap_uid
    end
  end

  ##
  # proxy eligible_submitter?, eligible_user?, eligible_campus_official?
  # 
  def method_missing(method, *args)
    if method.to_s =~ /^eligible_(.+)\?$/
      ldap_person && ldap_person.send(method)
    else
      super
    end
  end

  class << self
    FILTER_BY_OPTIONS = ["buyers", "admins", "disabled"].freeze

    def filter_by_options
      FILTER_BY_OPTIONS.dup.unshift("Select One")
    end

    def find_from_filter(filter_by)
      return User.all if (filter_by.blank? || !FILTER_BY_OPTIONS.include?(filter_by))

      if filter_by == "disabled"
        User.disabled
      elsif filter_by == "admins"
        User.admins
      elsif filter_by == "buyers"
        User.campus_buyers
      end
    end

    def new_from_attr_hash(attr_hash)
      user = self.new
      attr_hash.each { |key, val| user.send("#{key}=", val) }
      user
    end

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

    def find_or_new_by_ldap_uid(ldap_uid)
      return nil if ldap_uid.blank?


      if (user = find_by_ldap_uid(ldap_uid))
        user
      else
        user = User.new()

        ldap_person = UCB::LDAP::Person.find_by_uid(ldap_uid)
        if ldap_person.nil?
          return nil
        end

        attr_hash = attr_hash_from_ldap_person(ldap_person)
        attr_hash.each { |key, val| user.send("#{key}=", val) }
        user
      end
    end

    def new_from_ldap_uid(ldap_uid)
      ldap_person = ldap_uid.nil? ? nil : UCB::LDAP::Person.find_by_uid(ldap_uid)
      new_from_ldap_person(ldap_person)
    end

    def new_from_ldap_person(ldap_person)
      if ldap_person.nil?
        self.new()
      else
        user = self.new()
        attr_hash = attr_hash_from_ldap_person(ldap_person)
        attr_hash.each { |key, val| user.send("#{key}=", val) }
        user
      end
    end

    def attributes_hash_for_ldap_person(ldap_person)
      {
          :ldap_uid => ldap_person.uid.to_i,
          :first_name => ldap_person.first_name,
          :last_name => ldap_person.last_name,
          :email => ldap_person.email,
          :department => ldap_person.berkeleyeduunithrdeptname,
          :phone => ldap_person.phone
      }
    end

    def attr_hash_from_ldap_person(ldap_person)
      attributes_hash_for_ldap_person(ldap_person)
    end
  end

end
  
