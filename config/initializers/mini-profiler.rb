# require 'rack-mini-profiler'
# If using Rack::Deflater (e.g. set in config/application.rb), this must be
# after it, so use require: false in the Gemfile and then require it here.
# Rails.application.config.middleware.insert_after Rack::Deflater, Rack::MiniProfiler

# @TODO Create a PR in the rack-mini-profiler repository and ask for replacing
# the whitelist word and when it's replaced remove it from here
Rack::MiniProfiler.config.authorization_mode = :whitelist if Rails.env.production?
Rack::MiniProfiler.config.disable_caching = false
