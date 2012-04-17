class CreateAdminExtenuatingCircumstances < ActiveRecord::Migration
  def self.up
    create_table :ext_circumstances do |t|
      t.string :description
      t.boolean :enabled, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :ext_circumstances
  end
end
