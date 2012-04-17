class CreateOffCampusHosts < ActiveRecord::Migration
  def self.up
    create_table(:off_site_requests) do |t|
      t.boolean(:confirmed_by_campus_official)
      t.integer(:submitter_id)
      t.string(:hostname)
      t.boolean(:hostname_in_use)
      t.boolean(:arachne_or_socrates)
      t.string(:off_site_ip)
      t.string(:sponsoring_department)
      t.string(:off_site_service)
      t.boolean(:for_department_sponsor)
      t.string(:name_of_group)
      t.string(:relationship_of_group)
      t.boolean(:confirmed_service_qualifications)
      t.integer(:sla_reviewed_by)
      t.integer(:campus_buyer_id)
      t.integer(:campus_official_id)
      t.string(:cns_trk_number)
      t.integer(:status_id)
      t.boolean(:meets_ctc_criteria)
      t.string(:other_ext_circumstances)
      t.timestamps
    end
  end

  def self.down
    drop_table(:off_site_reqs)
    drop_table :schema_migrations;
  end
end
