source 'https://rubygems.org'

gem 'activerecord-import'
gem 'addressable'
gem 'ancestry'
gem 'bootsnap'
gem 'bootstrap-datepicker-rails'
gem 'cancancan'
gem 'comfortable_mexican_sofa'
gem 'countries', require: false
gem 'coveralls_reborn', require: false
gem 'date_validator'
gem 'devise'
gem 'dotenv-rails'
gem 'flutie'
gem 'jquery-placeholder-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', git: 'https://github.com/jquery-ui-rails/jquery-ui-rails'
gem 'jsonapi-serializer'
gem 'kaminari'
gem 'logstash-logger'
gem 'mime-types'
# Pinned because newer versions of this gem require Ruby 3.2+.
gem 'nokogiri', '~> 1.18.6', force_ruby_platform: true
gem 'oink'
gem 'oj'
# Pinned because the next step is migrating to ActiveStorage.
gem 'paperclip', '~> 5'
gem 'pg'
gem 'rack'
gem 'rack-attack'
gem 'rack-mini-profiler'
gem 'rails', '~> 7.1'
gem 'rails_admin', '~> 3.x'
gem 'rails_admin_tag_list', '~> 0.2.1'
gem 'recaptcha'
gem 'recipient_interceptor', require: false
gem 'record_tag_helper', '~> 1.0'
gem 'redcarpet'
gem 'rss'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'
gem 'sidekiq'
gem 'simple_form'
gem 'stackprof'
gem 'turnout'

# This needs to go last or tests fail. Their versions need to be pinned
# because there are breaking changes between major versions.
gem 'elasticsearch-model', '~> 7.0'
gem 'elasticsearch-rails', '~> 7.0'

group :development do
  gem 'allocation_tracer'
  gem 'bundle-audit'
  # Use main until https://github.com/zombocom/derailed_benchmarks/pull/241 is released.
  gem 'derailed_benchmarks', git: 'https://github.com/zombocom/derailed_benchmarks.git'
  gem 'memory_profiler'
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'ruby-prof'
  gem 'sham_rack'
end

group :development, :test, :assets do
  gem 'bourbon', '~> 3.x'
  gem 'coffee-rails'
  gem 'mini_racer', platforms: :ruby
  gem 'neat', '~> 1.3.x'
  gem 'sassc-rails'
  gem 'terser'
end

group :test do
  gem 'capybara-screenshot'
  gem 'capybara-selenium'
  gem 'curb'
  gem 'database_cleaner'
  gem 'elasticsearch-extensions'
  gem 'factory_bot_rails'
  gem 'parallel_tests'
  gem 'rack-test', require: 'rack/test'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers', '~> 1.1'
  gem 'rspec_junit_formatter'
  gem 'rspec-pride'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'simplecov', require: false
  gem 'test-prof'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
  gem 'webrick'
end
