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
# country_select has breaking changes in 2.x:
# https://github.com/stefanpenner/country_select/blob/master/UPGRADING.md
# It also removes CountrySelect::ISO_COUNTRIES_FOR_SELECT in 1.3, which is a
# breaking change for us.
gem 'country_select', '~> 1.2.0'
gem 'coveralls', require: false
gem 'date_validator'
gem 'devise'
gem 'dotenv-rails'
gem 'flutie'
gem 'high_voltage'
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
gem 'rack-mini-profiler', require: false
gem 'rails', '~> 5.2.0'
gem 'rails_admin'
gem 'rails_admin_tag_list', git: 'https://github.com/berkmancenter/rails_admin_tag_list'
gem 'recaptcha'
gem 'recipient_interceptor', require: false
gem 'record_tag_helper', '~> 1.0'
gem 'redcarpet'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'
gem 'simple_form'
gem 'skylight'
gem 'stackprof'
gem 'turnout'

# These need to go last or tests fail. Their versions need to be pinned
# because there are breaking changes in 6.
gem 'elasticsearch-model', '~> 5.0'
gem 'elasticsearch-rails', '~> 5.0'

group :development do
  gem 'bullet'
  gem 'derailed'
  gem 'memory_profiler'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'phantomjs'
  gem 'pry', '~> 0.10.4'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-collection_matchers', '~> 1.1', '>= 1.1.2'
  gem 'rspec-rails'
  gem 'ruby-prof'
  gem 'sham_rack'
end

group :development, :test, :assets do
  gem 'bourbon'
  gem 'coffee-rails'
  gem 'neat'
  gem 'sass-rails'
  gem 'therubyracer'
  gem 'uglifier'
end

group :test do
  gem 'curb'
  gem 'database_cleaner'
  gem 'elasticsearch-extensions'
  gem 'fakeweb'
  gem 'poltergeist'
  gem 'rack-test', require: 'rack/test'
  gem 'rails-controller-testing'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
