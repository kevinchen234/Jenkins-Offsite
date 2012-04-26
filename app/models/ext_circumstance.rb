class ExtCircumstance < ActiveRecord::Base
  attr_accessible :description, :enabled
  
  has_and_belongs_to_many :off_site_requests
  scope :enabled, where(:enabled => true)
  
  validates_presence_of :description
  validates_uniqueness_of :description
  validates_inclusion_of :enabled, :in => [true, false]

  def destroy
    if off_site_requests.present?
      raise DestroyWithReferencesError.new("Off-site Request", off_site_requests.length)
    end
    super
  end

  
  def self.select_list
    self.enabled.map { |ext| [ext.description, ext.id] }
  end

  def to_s
    description
  end
end
