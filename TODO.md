#TODO


## Rails 3.2.3 version upgrade 2012-04-17 by Vahid and Joel

### Questions

* Ask about protected_attributes methods in user model, offsite request model, etc.
  It seems that an offsite request can be created (via controler) calling #create which then calls
  #protected_attributes and there's no sanitization. Is this intended and/or ok?


## Rails 2.x version


### PENDING

* Use Rails Metal instead of app_monitor
* Test Mail notifications.
* Webrat Tests > (90% coverage)
* Install Downey's tab_nav plugin
* Server Side code does not prevent "unqualified" campus official from being set.


### CODE REVIEW

* Status: Just have the model be an ENUM.  See Downey's enum_helper
* Roles: Think about just using ENUMs.
* Tell Downey to send me Prototype sorting sample code
* Prefer has_many :through over habtm
* caccessor for itpolicy_email
* default_value_for plugin (off_site_request.rb after_initialize)
* off_site_request.rb#send_email_notification? => make method name more verbose, lose comments
* off_site_request.rb look into using delegate (submitter_ldap_uid, campus_official_ldap_uid) and friends: code is almost identical
*   validates_uniqueness_of :hostname, :unless => lambda { |r| r.hostname.blank? }
    validates_uniqueness_of :hostname, :allow_blank => true
*   validates_presence_of :relationship_of_group, :if => lambda { |r| r.for_department_sponsor? === false }
    validates_presence_of :relationship_of_group, :unless => for_deparment_sponsor?
* Sponsoring Department: List is WAY TOO LONG.  Think about using lightbox or autocomplete
* CTC => have link to page so user knows what CTC is
* Error messages for Off-Site Request form: highlight fields, put error messages next to field instead of at the top.
  This will eliminate the need to scroll up and down to see errors.

### REUSE

* ldap_search model
* CRUD messages
* Update ucb_rails_security generators (put user.rb code in a module?)






