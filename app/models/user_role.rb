class UserRole < ActiveRecord::Base
  #set_table_name("user_roles") Deprecated
  belongs_to :user
  belongs_to :role
  self.table_name="user_roles"
end
