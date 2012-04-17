class CreateAppHearbeatTable < ActiveRecord::Migration
  def self.up
    create_table :app_heartbeats, :force => true do |t|
      t.column "name", :string
    end
  end

  def self.down
    drop_table :app_heartbeats
  end
end
