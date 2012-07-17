# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# ExtCircumstances
ext_circ = ExtCircumstance.create!(
=begin  [{:description => "Better access to the root folders on offsite server"},
   {:description => "Can update website via blog template – no designer needed"},
   {:description => "Easier to install applications like WordPress blog"},
   {:description => "Easier to manage user accounts"},
   {:description => "Faster"},
   {:description => "Free and easier to modify (for example, Google)"},
   {:description => "Greater flexibility"},
   {:description => "Low cost"},
   {:description => "Off site collocation needed"},
   {:description => "Provides security and support of web server"},
   {:description => "Range of services available: database, programming languages"},
   {:description => "Service facilitates the construction, maintenance and design"},
   {:description => "Technical features"},
   {:description => "Technical features-UC server cannot support (for example, Wordpress)"},
   {:description => "Will not need to purchase a database"},
   {:description => "Uniquely available services"}]
=end
  [{:description=>"Social Security Numbers"},
    {:description=>"Credit Card Information (including truncated CC#s)"},
    {:description=>"Personally identifiable information - i.e. date tied to a name or biometric data (excluding data that is required by law to be published and data about the approving resource proprietor)"},
    {:description=>"Data that would cause negative financial or reputational  impact to the university if accessed by unauthorized persons"},
    {:description=>"Data that is not intended to be public" }])

# ROLES
roles = Role.create!(
  [{:name => "admin", :description => "Application administrator"},
   {:name => "buyer", :description => "Users with this role will appear in the campus buyers select list"}])


# STATUSES
statuses = Status.create!(
  [{:name => "Not Approved"},
   {:name => "Approved"}]
)
=begin
# ADMINS (User)
runner_attrs = {
  :first_name => "Steven",
  :last_name => "Hansen",
  :email => "runner@berkeley.edu",
  :department => "IST - Application Services",
  :ldap_uid => 61065,
  :enabled => true,
  :role_ids => [roles[0].id]
}
runner = User.new
runner.protected_attributes = runner_attrs
runner.save!

elise_attrs = {
  :first_name => "Elise",
  :last_name => "Jok",
  :email => "elisej@berkeley.edu",
  :department => "IST - Application Services",
  :ldap_uid => 5999,
  :enabled => true,
  :role_ids => [roles[0].id]
}
elise = User.new
elise.protected_attributes = elise_attrs
elise.save!


keft_attrs = {
  :first_name => "Karen",
  :last_name => "Eft",
  :email => "kareneft@berkeley.edu",
  :department => "Office of the CIO",
  :ldap_uid => 1298,
  :enabled => true,
  :role_ids => [roles[0].id]
}
keft = User.new
keft.protected_attributes = keft_attrs
keft.save!


erikad_attrs = {
  :first_name => "Erika",
  :last_name => "Donald",
  :email => "erikad@berkeley.edu",
  :department => "Office of the CIO",
  :ldap_uid => 206666,
  :enabled => true,
  :role_ids => [roles[0].id]  
}
erikad = User.new
erikad.protected_attributes = erikad_attrs
erikad.save!

vnadi_attrs = {
  :first_name => "Vahid",
  :last_name => "Nadi",
  :email => "vnadi@berkeley.edu",
  :department => "IST - CTS",
  :ldap_uid => 114027,
  :enabled => true,
  :role_ids => [roles[0].id]
}
vnadi = User.new
vnadi.protected_attributes = runner_attrs
vnadi.save!
=end