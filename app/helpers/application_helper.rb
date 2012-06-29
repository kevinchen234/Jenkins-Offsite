# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper

  def current_user
    #User.find_by_uid(ldap_user.uid)
    #Using a UCB::LDAP::Person for templates as that seems to be what they expect
    UCB::LDAP::Person.find_by_uid(ldap_user.uid)
  end

  def logged_in?
    ldap_user ? true : false
  end

  ######################################################################################

  def required_field_notice
    "<p style=\"text-align: center; font-weight: bold; font-style:italic;\">&quot;<span class=\"required\">*</span>&quot; indicates a required field.</p>"
  end

  def ldap_lookup_link_to(type, html_options = {})
    default_options = { :class => "lightbox lookup_widget" }
    valid_lookup_types = [:user, :campus_official, :submitter]
    link_to("Lookup in LDAP", ldap_search_url("ldap_search[search_for]" => type), default_options.merge!(html_options))
  end

  def view_or_edit_link_to(os_req)
    if os_req.status.approved?
      link_to("View", off_site_request_path(os_req), :class => "edit_button_widget")
    else
      link_to("Edit", edit_off_site_request_path(os_req), :class => "edit_button_widget")
    end
  end

  def delete_button(ar_instance, html_options = {})
    default_options = { :confirm => 'Are you sure?', :method => :delete, :class => "button_widget" }
    link_to("Delete", ar_instance, default_options.merge!(html_options))
  end

  def conditional_delete_button(ar_instance, html_option = {})
    if ar_instance.status.try(:not_approved?) && !ar_instance.new_record?
      delete_button(off_site_request_url(ar_instance))
    end
  end

  def delete_link_to(ar_instance, html_options = {})
    default_options = { :confirm => 'Are you sure?', :method => :delete, :class => "edit_button_widget" }
    link_to("Delete", ar_instance, default_options.merge!(html_options))
  end

  def new_link_to(name, options = {}, html_options = {})
    html_options.merge!(:class => "button_widget")
    link_to(name, options, html_options)
  end

  def edit_link_to(options = {}, html_options = {})
    default_options = {:class => "edit_button_widget"}
    link_to("Edit", options, default_options.merge!(html_options))
  end

  def display_message
    return format_message(:error) if flash[:error]
    return content_tag(:div, flash[:notice], :class => "flash_notice") if flash[:notice]
    return content_tag(:div, flash[:warn], :class => "flash_warn") if flash[:warn]
  end

  def format_message(msg_key)
    str = "<ul class='flash_#{msg_key}'>"
    flash[msg_key].each { |msg| str.concat("<li>#{msg}</li>") }
    str.concat("</ul>")
    str
  end

  def set_title(title)
    @title = title
    return nil
  end

  def title
    @title
  end

  def yes_no
    [["Yes", true], ["No", false]]
  end

  def yes_no_with_explanation
    [["Yes (for my department)", true],
     ["No (to enable another group)", false]]
  end

  def sla_reviewed_by
    OffSiteRequest::SLA_REVIEWED_BY.map { |k,v| [v, k] }
  end

  def ldap_person_query_string(user)
    str = ""
    str.concat("?ldap_uid=#{user.ldap_uid}")
    str.concat("&first_name=#{user.first_name}")
    str.concat("&last_name=#{user.last_name}")
    str.concat("&full_name=#{user.full_name}")
    str.concat("&email=#{user.email}")
    str.concat("&department=#{user.department}")
    str
  end

  def col_sort(col_name, attr_name, named_route, params)
    Rails.logger.debug("#{params[:sort_by]} => #{attr_name}")

    params = params.dup
    if (params[:sort_by] == attr_name) && params[:sort_order]
      params.delete(:sort_order)
      link_to(col_name, self.send(named_route, params.merge!(:sort_by => attr_name)))
    elsif params[:sort_by].nil? || (params[:sort_by] != attr_name)
      params.delete(:sort_order)
      link_to(col_name, self.send(named_route, params.merge!(:sort_by => attr_name)))
    else
      link_to(col_name, self.send(named_route, params.merge!(:sort_by => attr_name, :sort_order => "desc")))
    end
  end


  def nav_li(item, current)
    link = link_to(item[:label], item[:url], :id => item[:id])
    klass = current.to_s.gsub(/.+_tab_/, "") == item[:id].to_s ? 'current' : ''
    content_tag(:li, link, :class => klass)
  end

  def user_major_tabs
    tabs = [
        { :id => :site_home, :label => "Site Home", :url => root_url },
        { :id => :off_site_requests, :label => "Off-Site Requests", :url => off_site_requests_url },
    ]

    #str = "<li class=\"\"><a href=\"#{root_url}\" id=\"#{:site_home}\">Site Home</a></li>"
    #str+= "<li class=\"\"><a href=\"#{off_site_requests_url}\" id=\"#{:off_site_requests}\">Off-Site Requests</a></li>"

    # Show admins "Admin" tab
    if in_user_table? && role_names.map(&:to_sym).include?(:admin)
      tabs <<  { :id => :admin_home, :label => "Admin", :url => admin_root_url }
      #str+= "<li class=\"\"><a href=\"#{admin_root_url}\" id=\"#{:admin_home}\">Admin</a></li>"
    end
    tabs
    #str
  end

  def user_major_tabs_html
    lis = user_major_tabs.map { |item| nav_li(item, @major_tab) }
    #content_tag(:ul, lis.join("\n"))
    tabs = ""
    for tab in lis do
      tabs+=tab
    end
    tabs = "<ul>"+tabs+"</ul>"
    tabs.html_safe
  end


end
