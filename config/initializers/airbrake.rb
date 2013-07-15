if Rails.env.staging? || Rails.env.production?
  Airbrake.configure do |config|
    config.api_key = ENV['AIRBRAKE_API_KEY']
    config.host    = ENV['AIRBRAKE_API_HOST']
    config.port    = 80
    config.secure  = config.port == 443
    config.rescue_rake_exceptions = true
  end
end
