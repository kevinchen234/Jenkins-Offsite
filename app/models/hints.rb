module Hints
  class << self
    def confirmed_by_campus_official
      "Indicates that a confirmation email has been received by the campus offcial and they agree to the off-site hosting terms."
    end
    
    def submitter
      "Name of person that submitted the off-site hosting request."
    end

    def hostname
      "Hostname of .berkeley.edu website to be hosted off-site."
    end
    
    def hostname_in_use
      "Do you already use this name?"
    end

    def arachne_or_socrates
      "Is/was it hosted on Socrates or Arachne?"
    end

    def off_site_ip
      "Off-site IP address (if known) to which to point the hostname"
    end

    def sponsoring_department
      "Name of UC Berkeley department or unit sponsoring the activities."
    end
    
    def for_department_sponsor
      "Are the activities being conducted for your own department/unit, or being sponsored to enable another group\'s activities?"
    end
    
    def name_of_group
      "What is the name of the group?"
    end

    def relationship_of_group
      "What is the relationship to the Berkeley Campus of the organization(s) or individual(s) whose activities will be conducted via the remote location?"
    end
    
    def off_site_service
      "Name of off-site service (company or organization) that will host the offsite activities"
    end

    def confirmed_service_qualifications
      "Have you confirmed that the technical qualifications of hosting service are adequate?"
    end

    def ext_circumstances
      "What are the extenuating circumstances that require use of the proposed off-site service?"
    end
    
    def other_ext_circumstances
      "If you checked any of the sensitive information boxes above, please provide a detailed description of the information and its purpose to help IT Policy evaluate your request.Additional information may be requested.( See the <a href='https://security.berkeley.edu/data-authorization' Target='_NEW'>Data Authorization Process</a> for more information.)"
    end
    
    def campus_official
      "<span class='warn'>Email will be sent to this person confirming their agreement of the following \"Terms and Conditions\".</span><br/> Name of Berkeley Resource Proprietor agreeing to take responsibility for the <i>Off-Site Hosting Terms and Conditions</i>."
    end
    
    def meets_ctc_criteria
      "Will the activity take more than one year to develop, cost more than $100,000, or meet other <a href=\"http://technology.berkeley.edu/cio/fptis/sta/acquisition/index.html\">CTC (Campus Technology Council)</a> review criteria?"
    end

    def dns_instructions
      "Provide additional information about DNS, CNAMES, etc."
    end
  end
end
