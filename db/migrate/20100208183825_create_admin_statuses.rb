class CreateAdminStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :name
      t.boolean :enabled, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
  end
end
