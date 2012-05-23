class OffSiteRequestObserver < ActiveRecord::Observer

  def after_create(off_site_req)
    klass = self.class
    
    if klass.send_create_email?(off_site_req)
      OffSiteRequestMailer.email_to_submitter(off_site_req)
      OffSiteRequestMailer.email_to_it_policy(off_site_req, new_request = true)
      OffSiteRequestMailer.email_to_campus_official(off_site_req)
    end
  end
  
  def before_update(off_site_req)
    klass = self.class
    
    if klass.send_update_email?(off_site_req)
      OffSiteRequestMailer.email_to_it_policy(off_site_req, new_request = false)
      
      cc_submitter = true
      if klass.send_update_email_to_campus_official?(off_site_req)
        OffSiteRequestMailer.email_to_campus_official(off_site_req, cc_submitter)
      end
    end
  end

  protected
  
  class << self
    def send_update_email_to_campus_official?(req)
      req.campus_official_id_changed? || req.sponsoring_department_changed? || req.off_site_service_changed?
    end

    def send_update_email?(req)
      req.valid? && req.send_email_notification? && req.changed?
    end

    def send_create_email?(req)
      req.send_email_notification?
    end
  end
end
