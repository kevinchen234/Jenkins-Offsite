class OffSiteRequest < ActiveRecord::Base

  HUMANIZED_ATTRIBUTES = {
      :sla_reviewed_by => "TOS Reviewed By"
  }

  IP_REGEXP = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
  HOSTNAME_REGEXP = /\.berkeley\.edu$/
  REQ_MSG = "can't be blank"

  SLA_REVIEWED_BY = {
      (CAMPUS_BUYER = 0) => "Official Campus Buyer",
      (CONTRACTS_OFFICE = 1) => "The Business Contracts Office",
  }

  attr_accessor :send_email_notification

  attr_accessible \
   :arachne_or_socrates,
   :campus_buyer_id,
   :campus_official_full_name,
   :campus_official_ldap_uid,
   :confirmed_service_qualifications,
   :ext_circumstance_ids,
   :for_department_sponsor,
   :hostname,
   :hostname_in_use,
   :meets_ctc_criteria,
   :name_of_group,
   :off_site_ip,
   :off_site_service,
   :other_ext_circumstances,
   :relationship_of_group,
   :sponsoring_department

  attr_protected \
  :campus_official_id,
  :status_id,
  :submitter_id

  belongs_to :campus_official, :class_name => 'User'
  belongs_to :submitter, :class_name => 'User'
  belongs_to :campus_buyer, :class_name => 'User'
  belongs_to :status
  has_and_belongs_to_many :ext_circumstances

  validates_presence_of \
  :submitter_id,
  :campus_official_id,
  :hostname,
  :sponsoring_department,
  :off_site_service,
  :status_id

  validates_uniqueness_of :hostname, :unless => lambda { |r| r.hostname.blank? }
  validates_format_of :hostname, :with => HOSTNAME_REGEXP, :unless => lambda { |r| r.hostname.blank? },
                      :message => "must be .berkeley.edu"
  validates_presence_of :name_of_group, :if => lambda { |r| r.for_department_sponsor === false }
  validates_presence_of :relationship_of_group, :if => lambda { |r| r.for_department_sponsor? === false }
  validates_inclusion_of :hostname_in_use, :in => [true, false], :message => REQ_MSG
  validates_inclusion_of :confirmed_by_campus_official, :in => [true, false], :message => REQ_MSG,
                         :if => lambda { |r| r.confirmed_by_campus_official.present? }
  validates_inclusion_of :arachne_or_socrates, :in => [true, false], :if => lambda { |r| r.hostname_in_use? },
                         :message => REQ_MSG
  validates_inclusion_of :confirmed_service_qualifications, :in => [true, false], :message => REQ_MSG
  validates_inclusion_of :for_department_sponsor, :in => [true, false], :message => REQ_MSG
  validates_inclusion_of :meets_ctc_criteria, :in => [true, false], :message => REQ_MSG
  validates_format_of :off_site_ip, :with => IP_REGEXP, :unless => lambda { |r| r.off_site_ip.blank? }
  validate :validate_campus_official, :validate_submitter, :validate_status

  after_initialize :set_default_status

  #def before_destroy
  #  if status.approved?
  #    errors.add_to_base("Really, delete an APPROVED request?!! If you really want to delete it, update its status then delete.")
  #    false
  #  end
  #end

  def destroy
    if status.approved?
      errors[:base] << "Really, delete an APPROVED request?!! If you really want to delete it, update its status then delete."
      return false
    end
    super
  end

  def validate_campus_official
    if campus_official
      p = UCB::LDAP::Person.find_by_uid(campus_official.ldap_uid)
      if p.nil? || !p.eligible_campus_official?
        errors.add(:campus_official_id, "does not have required affiliations.")
      end
    end
  end

  def validate_submitter
    if submitter
      p = UCB::LDAP::Person.find_by_uid(submitter.ldap_uid)
      if p.nil? || !p.eligible_submitter?
        errors.add(:submitter_id, "does not have required affiliations.")
      end
    end
  end

  def validate_status
    if !status_id.nil? && !Status.all.map(&:id).include?(status_id)
      errors.add(:status_id, "is not a valid status.")
    end
  end

  def set_default_status
    if read_attribute(:status_id).nil?
      self.status = Status::NOT_APPROVED
    end
  end

#TODO
#  def self.human_attribute_name(attr)
#    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
#  end

  def enforce_validation=(bool)
    @enforce_validation = bool
  end

  def enforce_validation
    @enforce_validation || true
  end

  def enforce_validation?
    (["false", false, nil].include?(enforce_validation)) ? false : true
  end

  def protected_attributes=(params = {})
    self.submitter_ldap_uid = params[:submitter_ldap_uid]
    self.submitter_full_name = params[:submitter_full_name]
    self.cns_trk_number = params[:cns_trk_number]
    self.status_id = params[:status_id]
    self.confirmed_by_campus_official = params[:confirmed_by_campus_official]
    self.enforce_validation = params[:enforce_validation]
    self.comment = params[:comment]
  end

  def submitter_full_name
    @submitter_full_name || submitter.try(:full_name)
  end

  def submitter_ldap_uid
    @submitter_ldap_uid || submitter.try(:ldap_uid)
  end

  def submitter_full_name=(name)
    @submitter_full_name = name
  end

  def submitter_ldap_uid=(ldap_uid)
    @submitter_ldap_uid = ldap_uid
    submitter = User.find_or_new_by_ldap_uid(ldap_uid)
    if submitter.try(:new_record?)
      submitter.enabled = true
      submitter.save!
    end
    self.submitter = submitter
  end

  def campus_official_full_name
    @campus_official_full_name || campus_official.try(:full_name)
  end

  def campus_official_ldap_uid
    @campus_official_ldap_uid || campus_official.try(:ldap_uid)
  end

  def campus_official_full_name=(name)
    @campus_official_full_name = name
  end

  def campus_official_ldap_uid=(ldap_uid)
    co = User.find_by_ldap_uid(ldap_uid)
    raise ArgumentError if !co

    @campus_official_ldap_uid = ldap_uid.to_i
    self.campus_official = co
  end

  def to_csv
    attrs = csv_attributes
    FasterCSV.generate_line(attrs.keys.sort.inject([]) { |accum, elem| accum << attrs[elem] })
  end

  def csv_attributes
    attrs = self.attributes.dup
    attrs.delete_if { |key, val| key =~ /^(.+)_id$/ }
    attrs.delete("id")
    attrs["submitter"] = self.submitter.try(:full_name)
    attrs["campus_buyer"] = self.campus_buyer.try(:full_name)
    attrs["campus_official"] = self.campus_official.try(:full_name)
    attrs["status"] = self.status.try(:name)
    attrs["sla_reviewed_by"] = sla_reviewed_by.nil? ? nil : SLA_REVIEWED_BY[sla_reviewed_by]
    attrs["ext_circumstances"] = ext_circumstances.map(&:description).join(", ")
    attrs["created_at"] = created_at.nil? ? nil : created_at.to_s(:mdy)
    attrs["updated_at"] = updated_at.nil? ? nil : updated_at.to_s(:mdy)
    attrs
  end

  ##
  # When a normal user saves their request, we need to send out email notifications.
  # On the other hand, if and admin saves a request, no email should be sent.  This
  # flag lets our observer determine if email should be sent out after a save.
  #
  def send_email_notification?
    send_email_notification
  end


  class << self
    def csv_header_cols
      header = columns.map { |col| (col.name =~ /^(.+)_id$/) ? $1 : col.name }
      header.delete("id")
      header << "ext_circumstances"
      header.sort
    end

    def csv_header
      FasterCSV.generate_line(csv_header_cols)
    end

    def sortable_find_all(params)
      self.all(:include => [:status, :submitter], :order => OffSiteRequest.sort_param(params))
    end

    def sort_param(params = {})
      sort_order = params[:sort_order] ? params[:sort_order].downcase : nil
      sort_by = params[:sort_by] || " ASC"

      @valid_params ||= [
          :cns_trk_number, :sponsoring_department, :hostname, :submitter, :status, :created_at, :updated_at
      ]

      return @valid_params[0] if !@valid_params.include?(sort_by.to_sym)

      if sort_by.to_sym == :status
        sort_by = "statuses.name"
      elsif sort_by.to_sym == :submitter
        sort_by = "users.first_name"
      end

      (sort_order && sort_order.downcase == "desc") ? "#{sort_by} DESC" : sort_by
    end
  end
end
