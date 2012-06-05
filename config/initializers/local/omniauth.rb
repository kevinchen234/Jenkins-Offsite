Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, :host => AppConfig[:cas_url]
end