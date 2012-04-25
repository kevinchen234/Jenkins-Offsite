class CreateUcbRailsSecurityTables < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.string :ldap_uid
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :department
      t.timestamps
    end
    
    create_table "roles", :force => true do |t|
      t.string :name
      t.string :description
      t.timestamps
    end

    create_table "user_roles", :force => true, :id => false do |t|
      t.integer :user_id
      t.integer :role_id
      t.timestamps
    end
  end

  def self.down
    drop_table :users
    drop_table :roles
    drop_table :user_roles
  end
end