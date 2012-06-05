class SessionsController < ApplicationController
  skip_before_filter(:ensure_authenticated_user)

  def new()
    redirect_to("/auth/cas")
  end

  def create()
    session[:ldap_uid] = request.env['omniauth.auth'].uid()
    redirect_to(session[:original_url] || off_site_requests_path)
  end

  def destroy()
    reset_session()
    redirect_to("%s?url=%s" % [AppConfig[:cas_logout], root_url])
  end
end