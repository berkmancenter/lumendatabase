require 'rack-mini-profiler'

# This must be after Rack::Deflater (which we set up in config/application.rb),
# so we use require: false in the Gemfile and then require it here.
Rails.application.config.middleware.insert_after Rack::Deflater, Rack::MiniProfiler

Rack::MiniProfiler.config.authorization_mode = :whitelist if Rails.env.production?
Rack::MiniProfiler.config.disable_caching = false
