class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => "user_roles"
  

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  ADMIN = 'admin'
  BUYER = 'buyer'
  
  ##
  # Make sure we can't delete this record if other records depend on it.
  #
  def before_destroy
    if !users.empty?
      errors.add_to_base("Unable to delete:  record is referenced by #{users.length} User records.")
      false
    end
  end
end
