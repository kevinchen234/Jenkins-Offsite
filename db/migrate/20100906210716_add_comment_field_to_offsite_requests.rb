class AddCommentFieldToOffsiteRequests < ActiveRecord::Migration
  def self.up
    add_column(:off_site_requests, :comment, :text)
  end

  def self.down
    remove_column(:off_site_requests, :comment)
  end
end
