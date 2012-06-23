module Admin::AdminHelper

  def login_as_user_button(_user)
    if _user.status
      button_to('Login', login_admin_user_path(_user.id), :method => :get)
    end
  end
  
  def admin_major_tabs
    [
     { :id => :site_home, :label => "Site Home", :url => root_url },
     { :id => :off_site_requests, :label => "Off-Site Requests", :url => admin_off_site_requests_url },
     { :id => :users, :label => "Users", :url => admin_users_url },
     { :id => :roles, :label => "Roles", :url => admin_roles_url },
     { :id => :ext_circumstances, :label => "Ext. Circumstances", :url => admin_ext_circumstances_url },
     { :id => :status, :label => "Status", :url => admin_statuses_url },
    ]
    #str =  "<li class=\"\"><a href=\"#{root_url}\" id=\"#{:site_home}\">Site Home</a></li>"
    #str += "<li class=\"\"><a href=\"#{admin_off_site_requests_url}\" id=\"#{:off_site_requests}\">Off-Site Requests</a></li>"
    #str += "<li class=\"\"><a href=\"#{admin_users_url}\" id=\"#{:users}\">Users</a></li>"
    #str += "<li class=\"\"><a href=\"#{admin_roles_url}\" id=\"#{:roles}\">Roles</a></li>"
    #str += "<li class=\"\"><a href=\"#{admin_ext_circumstances_url}\" id=\"#{:ext_circumstances}\">Ext. Circumstances</a></li>"
    #str += "<li class=\"\"><a href=\"#{admin_statuses_url}\" id=\"#{:status}\">Status</a></li>"
    #str
  end

  def admin_major_tabs_html
    lis = admin_major_tabs.map { |item| nav_li(item, @major_tab) }
    #content_tag(:ul, lis.join("\n"))
    tabs = ""
    for tab in lis do
      tabs+=tab
    end
    tabs.html_safe
  end
  
end
