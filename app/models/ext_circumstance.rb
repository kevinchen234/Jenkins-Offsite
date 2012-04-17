class ExtCircumstance < ActiveRecord::Base
  attr_accessible :description, :enabled
  
  has_and_belongs_to_many :off_site_requests
  scope :enabled, where(:enabled => true)
  
  validates_presence_of :description
  validates_uniqueness_of :description
  validates_inclusion_of :enabled, :in => [true, false]
  
  ##
  # Make sure we can't delete this record if other records depend on it.
  #
  def before_destroy
    if !off_site_requests.empty?
      errors.add_to_base("Unable to delete:  record is referenced by #{off_site_requests.length} User records")
      false
    end
  end
  
  def self.select_list
    self.enabled.map { |ext| [ext.description, ext.id] }
  end

  def to_s
    description
  end
end
