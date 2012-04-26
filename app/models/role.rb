class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => "user_roles"
  

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  
  ADMIN = 'admin'
  BUYER = 'buyer'

  def destroy
    if users.present?
      raise DestroyWithReferencesError.new("User", users.length)
    end
    super
  end
end
