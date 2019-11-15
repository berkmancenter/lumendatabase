require 'rack-mini-profiler'

# If using Rack::Deflater (e.g. set in config/application.rb), this must be after it,
# so we use require: false in the Gemfile and then require it here.
# Rails.application.config.middleware.insert_after Rack::Deflater, Rack::MiniProfiler

Rack::MiniProfiler.config.authorization_mode = :whitelist if Rails.env.production?
Rack::MiniProfiler.config.disable_caching = false
