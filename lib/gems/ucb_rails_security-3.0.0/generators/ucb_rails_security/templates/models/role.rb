class Role < ActiveRecord::Base
  has_and_belongs_to_many(:users, :join_table => "user_roles", :order => 'last_name')
                        
  validates_presence_of :name
  validates_uniqueness_of :name

  
  def formatted_created_at()
    created_at.strftime('%m-%d-%Y')
  end
  
  def formatted_updated_at()
    updated_at.strftime('%m-%d-%Y')
  end

  def users_menu_list()
    self.users.map { |u| [u.display_name, u.id] }
  end
  
  def non_users_menu_list
    self.non_users.map { |u| [u.display_name, u.id] }    
  end
  
  def non_users
    sql = %(
      SELECT users.* FROM users LEFT JOIN user_roles 
      ON (users.id = user_roles.user_id AND user_roles.role_id = #{id})
      WHERE user_roles.role_id IS NULL
    )
    User.find_by_sql(sql)
  end
end
