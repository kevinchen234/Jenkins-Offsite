# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100906210716) do

  create_table "app_heartbeats", :force => true do |t|
    t.string "name"
  end

  create_table "ext_circumstances", :force => true do |t|
    t.string   "description"
    t.boolean  "enabled",     :default => true
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "ext_circumstances_off_site_requests", :id => false, :force => true do |t|
    t.integer "off_site_request_id"
    t.integer "ext_circumstance_id"
  end

  create_table "off_site_requests", :force => true do |t|
    t.boolean  "confirmed_by_campus_official"
    t.integer  "submitter_id"
    t.string   "hostname"
    t.boolean  "hostname_in_use"
    t.boolean  "arachne_or_socrates"
    t.string   "off_site_ip"
    t.string   "sponsoring_department"
    t.string   "off_site_service"
    t.boolean  "for_department_sponsor"
    t.string   "name_of_group"
    t.string   "relationship_of_group"
    t.boolean  "confirmed_service_qualifications"
    t.integer  "sla_reviewed_by"
    t.integer  "campus_buyer_id"
    t.integer  "campus_official_id"
    t.string   "cns_trk_number"
    t.integer  "status_id"
    t.boolean  "meets_ctc_criteria"
    t.string   "other_ext_circumstances"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "comment"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "statuses", :force => true do |t|
    t.string   "name"
    t.boolean  "enabled",    :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "user_roles", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "ldap_uid"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "department"
    t.boolean  "enabled",    :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

end
