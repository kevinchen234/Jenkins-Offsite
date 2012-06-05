class AppConfig
  VERSION = "1.0.0"

  @conf = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
  @conf[:version] = VERSION

  def self.[](key)
    @conf[key.to_s]
  end

end
