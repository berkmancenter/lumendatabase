source 'https://rubygems.org'

gem 'active_model_serializers', '~> 0.8.3'
gem 'activerecord-import'
gem 'acts-as-taggable-on'
gem 'addressable'
gem 'ancestry'
gem 'bootstrap-datepicker-rails'
gem 'cancancan'
gem 'country_select'
gem 'coveralls', require: false
gem 'date_validator'
gem 'devise'
gem 'dotenv-rails'
gem 'flutie'
gem 'high_voltage'
gem 'html2md', require: false
gem 'jquery-placeholder-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
# kaminari is locked because we've monkeypatched it to work around
# slow postgres table counts on large tables.
gem 'kaminari', '0.14.1'
gem 'lograge'
gem 'loofah', '>= 2.2.3'
gem 'mime-types'
gem 'minitest'
gem 'mysql2', '~> 0.4.1'
gem 'oink'
gem 'paperclip', '~> 5'
gem 'pg', '0.20.0'
gem 'rack', '>= 1.6.11'
gem 'rack-attack'
gem 'rack-mini-profiler', '~> 0.9.9'
gem 'rails', '~> 4.2.11'
gem 'rails_admin'
gem 'rails_admin_tag_list'
# Monkeypatched temporarily for debugging purposes
gem 'recaptcha'
gem 'recipient_interceptor', require: false
gem 'redcarpet'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'
gem 'simple_form'
gem 'skylight'
gem 'stackprof'
gem 'turnout'

# These need to go last or tests fail.
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

group :development do
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'derailed'
  gem 'foreman'
  gem 'memory_profiler'
end

group :development, :test do
  gem 'factory_girl_rails'
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
  gem 'bourne', require: false
  gem 'curb'
  gem 'database_cleaner'
  gem 'elasticsearch-extensions'
  gem 'fakeweb'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rack-test', require: 'rack/test'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'
  gem 'simplecov', require: false
  gem 'spork-rails', git: 'https://github.com/sporkrb/spork-rails'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
