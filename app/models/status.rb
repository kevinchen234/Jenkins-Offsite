class Status < ActiveRecord::Base
  attr_accessible(:name, :enabled)
  
  has_many :off_site_reqs

  validates_presence_of :name
  validates_uniqueness_of :name, :if => lambda { |r| !r.name.blank? }
  validates_inclusion_of :enabled, :in => [true, false]

  def approved?
    name.downcase.eql?("approved")
  end

  def not_approved?
    name.downcase.eql?("not approved")
  end

  def to_s
    name
  end
end
