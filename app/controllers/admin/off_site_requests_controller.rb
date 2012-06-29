class Admin::OffSiteRequestsController < Admin::AdminController
  before_filter :major_tab_off_site_requests
  before_filter :load_os_req, :only => [:edit, :update, :destroy]
  before_filter :build_department_list, :only => [:new, :edit, :update, :create]
  before_filter :build_status_list, :only => [:new, :edit, :update, :create]
  before_filter :build_campus_buyers_list, :only => [:new, :edit, :update, :create]
  before_filter :build_ext_circumstances_list, :only => [:new, :edit, :update, :create]    
  
  def index
    @os_reqs = OffSiteRequest.sortable_find_all(params)
    respond_to do |format|
      format.html
      format.csv do
        response.headers["Content-Type"]        = "text/csv; charset=UTF-8; header=present"
        response.headers["Content-Disposition"] = "attachment; filename=off-site-requests.csv"
      end
    end
  end
  
  def new
    @os_req = OffSiteRequest.new
  end

  def edit
  end
  
  def create
    @os_req = OffSiteRequest.new("hostname"=>params[:off_site_request][:hostname],
                                 "hostname_in_use"=>params[:off_site_request][:hostname_in_use],
                                 "arachne_or_socrates"=>params[:off_site_request][:arachne_or_socrates],
                                 "sponsoring_department"=>params[:off_site_request][:sponsoring_department],
                                 "for_department_sponsor"=>params[:off_site_request][:for_department_sponsor],
                                 "name_of_group"=>params[:off_site_request][:name_of_group],
                                 "relationship_of_group"=>params[:off_site_request][:relationship_of_group],
                                 "off_site_ip"=>params[:off_site_request][:off_site_ip],
                                 "off_site_service"=>params[:off_site_request][:off_site_service],
                                 "confirmed_service_qualifications"=>params[:off_site_request][:confirmed_service_qualifications],
                                 "ext_circumstance_ids"=>params[:off_site_request][:ext_circumstance_ids],
                                 "other_ext_circumstances"=>params[:off_site_request][:other_ext_circumstances],
                                 "meets_ctc_criteria"=>params[:off_site_request][:meets_ctc_criteria],
                                 "campus_official_ldap_uid"=>params[:off_site_request][:campus_official_ldap_uid],
                                 "created_at"=>params[:off_site_request][:created_at],
                                 "updated_at"=>params[:off_site_request][:updated_at])

    @os_req.protected_attributes = params[:off_site_request]
    
    if !@os_req.enforce_validation?
      @os_req.save(:validate => false)
      flash[:notice] = msg_created(@os_req)
      redirect_to edit_admin_off_site_request_url(@os_req)      
    elsif @os_req.save
      flash[:notice] = msg_created(@os_req)
      redirect_to edit_admin_off_site_request_url(@os_req)
    else
      render("new")
    end
  end

  def update
    @os_req.attributes=({"hostname"=>params[:off_site_request][:hostname],
                         "hostname_in_use"=>params[:off_site_request][:hostname_in_use],
                         "arachne_or_socrates"=>params[:off_site_request][:arachne_or_socrates],
                         "sponsoring_department"=>params[:off_site_request][:sponsoring_department],
                         "for_department_sponsor"=>params[:off_site_request][:for_department_sponsor],
                         "name_of_group"=>params[:off_site_request][:name_of_group],
                         "relationship_of_group"=>params[:off_site_request][:relationship_of_group],
                         "off_site_ip"=>params[:off_site_request][:off_site_ip],
                         "off_site_service"=>params[:off_site_request][:off_site_service],
                         "confirmed_service_qualifications"=>params[:off_site_request][:confirmed_service_qualifications],
                         "ext_circumstance_ids"=>params[:off_site_request][:ext_circumstance_ids],
                         "other_ext_circumstances"=>params[:off_site_request][:other_ext_circumstances],
                         "meets_ctc_criteria"=>params[:off_site_request][:meets_ctc_criteria],
                         "campus_official_ldap_uid"=>params[:off_site_request][:campus_official_ldap_uid]})
    @os_req.protected_attributes = params[:off_site_request]

    if !@os_req.enforce_validation?
      @os_req.save(:validate => false)
      flash[:notice] = msg_updated(@os_req)
      redirect_to edit_admin_off_site_request_url(@os_req)
    elsif @os_req.save
      flash[:notice] = msg_updated(@os_req)
      redirect_to edit_admin_off_site_request_url(@os_req)
    else
      render("edit")
    end
  end
  
  def destroy
    if @os_req.destroy
      flash[:notice] = msg_destroyed(@os_req)
      redirect_to admin_off_site_requests_url
    else
      flash[:error] = msg_errors(@os_req)
      redirect_to edit_admin_off_site_request_url(@os_req)
    end
  end
  

  protected

  def load_os_req
    @os_req = OffSiteRequest.find(params[:id])    
  end
  
  def build_department_list
    @department_list = UCB::LDAP::Org.build_department_list
  end

  def build_status_list
    @status_list = Status.all
  end

  def build_campus_buyers_list
    @campus_buyers_list = User.campus_buyers_select_list
  end

  def build_ext_circumstances_list
    @ext_circumstances_list = ExtCircumstance.select_list
  end
  
end
