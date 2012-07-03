class AddIdToUserRoles < ActiveRecord::Migration
  def change
    add_column :user_roles, :id, :primary_key
  end
end
