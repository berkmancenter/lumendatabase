Rack::MiniProfiler.config.authorization_mode = :whitelist if Rails.env.production?
Rack::MiniProfiler.config.disable_caching = false
