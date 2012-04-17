class OffSiteRequestMailer < ActionMailer::Base

  def email_to_itpolicy(offsite_req, new_request = true)
    @offsite_req = offsite_req
    @itpolicy_email = itpolicy_email
    @new_request = new_request
    mail(
        :from => from_app_email,
        :to => itpolicy_email,
        :subject => subject_content("IT Policy Notification")
    )
  end

  def email_to_campus_official(offsite_req, cc_submitter = false)
    @offsite_req = offsite_req
    @itpolicy_email = itpolicy_email
    mail(
        :from => from_email,
        :to => campus_official_email,
        :cc => (cc_submitter ? submitter_email : nil),
        :subject => subject_content("Campus Official Notification")
    )
  end

  def email_to_submitter(offsite_req)
    @offsite_req = offsite_req
    @itpolicy_email = itpolicy_email
    mail(
        :from => from_email,
        :to => submitter_email,
        :subject => subject_content("Submitter Notification")
    )
  end

  protected

  def current_user()
    @offsite_req.submitter
  end

  def from_email()
    if Rails.env.production?
      "IT Policy <#{App.itpolicy_email}>"
    else
      "IT Policy - #{Rails.env} <#{App.itpolicy_email}>"
    end
  end

  def from_app_email()
    if Rails.env.production?
      "Off-Site Host Request <admin@offsitehosting.berkeley.edu>"
    else
      "Off-Site Host Request - [#{Rails.env}] <admin@offsitehosting.berkeley.edu>"
    end
  end

  def subject_content(audience)
    "Off-Site Host Request: #{audience} - (#{@offsite_req.hostname})"
  end

  def email_for_env(who)
    if ["development", "dev_integration", "quality_assurance", "app_scan"].include?(Rails.env)
      current_user.email
    else
      @offsite_req.send(who).email
    end
  end

  def submitter_email()
    email_for_env(:submitter)
  end

  def campus_official_email()
    email_for_env(:campus_official)
  end

  def itpolicy_email()
    if ["development", "dev_integration", "app_scan"].include?(Rails.env)
      current_user.email
    else
      App.itpolicy_email
    end
  end
end
