class LdapSearch
  include ActiveSupport
  #extend ActiveModel::Naming

  class LSException < StandardError; end
  
  SEARCH_BY_OPTIONS = [:ldap_uid, :last_first_name, :last_name, :first_name, :email].freeze
  SEARCH_FOR_OPTIONS = [:campus_official, :submitter, :user].freeze
  
  attr_accessor :search_by, :search_value, :search_for

  def initialize(params = {})
    return if params.nil?
    @search_by = params[:search_by] if params[:search_by]
    @search_value = params[:search_value] if params[:search_value]
    @search_for = params[:search_for]
  end
  
  def find
    #Not sure if we need to take care of these edge cases
    #Live site seems to ignore bad requests
    #Returning nil is the closest I've gotten so far to that
    if search_for.nil?
      return
    end

    unless SEARCH_FOR_OPTIONS.include?(search_for.to_sym)
      #raise(LSException, "invalid :search_for option: #{search_for}")
      return
    end
    
    return [] unless valid_find_options?

    params = { :search_by => search_by, :search_value => search_value }
    filter = self.class.create_filter(params)
    filter[:search_for] = search_for
    Rails.logger.debug(filter.inspect)
    
    users = self.class.find_in_ldap(filter).map do |ldap_record|
      user = User.new_from_ldap_person(ldap_record)
      user.ldap_person = ldap_record
      user
    end
    users.sort_by(&:display_name)
  end
  
  def valid_find_options?
    return false if search_by.blank?
    return false if search_value.blank?
    SEARCH_BY_OPTIONS.include?(search_by.try(:to_sym)) ? true : false
  end
  
  ##
  # Hack to get formtastic to work
  #
  def new_record?
  end
  
  ##
  # Hack to get formtastic to work
  #
  def self.human_name
  end


  class << self    
    def search_by_options
      [['Last Name', 'last_name'],
       ['Last Name, First Name', 'last_first_name'],
       ['First Name', 'first_name'],
       ['Ldap Uid', 'ldap_uid'],
       ['Email', 'email']]
    end
    
    def create_filter(params = {})
      filter = {}
      case params[:search_by]
        when 'ldap_uid'
          filter[:uid] = params[:search_value]
        when 'last_first_name'
          filter[:sn], filter[:givenname] = params[:search_value].split(/,\s*/, 2)
        when 'last_name'
          filter[:sn] = params[:search_value]
        when 'first_name'
          filter[:givenname] = params[:search_value]
        when 'email'
          filter[:mail] = params[:search_value]
      end
      filter
    end

    def find_in_ldap(filter)
      search_for = filter.delete(:search_for).to_sym
      people = UCB::LDAP::Person.search(:filter => filter)
      Rails.logger.debug("Found: #{people.length} records")      
      people
    end
  end

end
