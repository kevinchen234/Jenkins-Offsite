class OffsiteHostingNewColumn < ActiveRecord::Migration
  def up
    add_column :off_site_requests, :additional_DNS_instructions, :string
  end

  def down
    remove_column :off_site_requests, :additional_DNS_instructions
  end
end
