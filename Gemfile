source 'https://rubygems.org'

# Pinned due to development difficulties with AMS 0.9/0.10.
gem 'active_model_serializers', '~> 0.8.3'
gem 'activerecord-import'
gem 'acts-as-taggable-on'
gem 'addressable'
gem 'ancestry'
gem 'bootsnap'
gem 'bootstrap-datepicker-rails'
gem 'cancancan'
gem 'comfortable_mexican_sofa'
# country_select has breaking changes in 2.x:
# https://github.com/stefanpenner/country_select/blob/master/UPGRADING.md
# It also removes CountrySelect::ISO_COUNTRIES_FOR_SELECT in 1.3, which is a
# breaking change for us.
gem 'country_select', '~> 1.2.0'
gem 'coveralls', '~> 0.8.0', require: false
gem 'date_validator'
gem 'devise'
gem 'dotenv-rails'
gem 'flutie'
gem 'jquery-placeholder-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'kaminari'
gem 'lograge'
gem 'mime-types'
gem 'oink'
# Pinned because the next step is migrating to ActiveStorage.
gem 'paperclip', '~> 5'
gem 'pg', '~> 1.1.4'
gem 'rack'
gem 'rack-attack'
# The ActiveSupport::Notifications default causes rails to hang on startup, so
# we fall back to the earlier enable_rails_patches behavior.
gem 'rack-mini-profiler', require: ['enable_rails_patches', 'rack-mini-profiler']
gem 'rails', '~> 6.1.0'
gem 'rails_admin'
gem 'rails_admin_tag_list', '~> 0.2.1'
gem 'recaptcha'
gem 'recipient_interceptor', require: false
gem 'record_tag_helper', '~> 1.0'
gem 'redcarpet'
gem 'rss'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'
gem 'simple_form'
gem 'skylight'
gem 'stackprof'
gem 'turnout'

# This needs to go last or tests fail. Their versions need to be pinned
# because there are breaking changes between major versions.
gem 'elasticsearch-model', '~> 7.0'
gem 'elasticsearch-rails', '~> 7.0'

group :development do
  gem 'allocation_tracer'
  gem 'derailed'
  gem 'memory_profiler'
end

group :development, :test do
  gem 'pry', '~> 0.10.4'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'ruby-prof'
  gem 'sham_rack'
end

group :development, :test, :assets do
  gem 'bourbon'
  gem 'coffee-rails'
  gem 'mini_racer'
  gem 'neat'
  gem 'sassc-rails'
  gem 'terser'
end

group :test do
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
  gem 'shoulda-matchers', '~> 4.0'
  gem 'simplecov', require: false
  gem 'test-prof'
  gem 'timecop'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
  gem 'webrick'
end
