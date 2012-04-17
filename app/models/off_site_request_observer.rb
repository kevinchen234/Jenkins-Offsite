class OffSiteRequestObserver < ActiveRecord::Observer
  def after_create(offsite_req)
    klass = self.class
    
    if klass.send_create_email?(offsite_req)
      OffSiteRequestMailer.email_to_submitter(offsite_req)
      OffSiteRequestMailer.email_to_itpolicy(offsite_req, new_request = true)
      OffSiteRequestMailer.email_to_campus_official(offsite_req)
    end
  end
  
  def before_update(offsite_req)
    klass = self.class
    
    if klass.send_update_email?(offsite_req)
      OffSiteRequestMailer.email_to_itpolicy(offsite_req, new_request = false)
      
      cc_submitter = true
      if klass.send_update_email_to_campus_official?(offsite_req)
        OffSiteRequestMailer.email_to_campus_official(offsite_req, cc_submitter)
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
