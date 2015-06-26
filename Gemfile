source 'https://rubygems.org'

ruby '2.0.0'

gem 'bourbon'
gem 'neat'
gem 'flutie'
gem 'high_voltage'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'pg'
gem 'rails', '~> 3.2.11'
gem 'recipient_interceptor'
gem 'simple_form'
gem 'strong_parameters'
gem 'paperclip', git: 'http://github.com/thoughtbot/paperclip.git'
gem 'active_model_serializers', '~> 0.8.0'
gem 'acts-as-taggable-on'
gem 'ancestry'
gem 'devise'
gem 'rails_admin', '~>0.4.8'
# kaminari is locked because we've monkeypatched it to work around
# slow postgres table counts on large tables.
gem 'kaminari', '0.14.1'
gem 'redcarpet', '~>2.3.0'
gem 'country_select'
gem 'tire', '~> 0.6.0'
gem 'select2-rails'
gem 'bootstrap-datepicker-rails'
gem 'cancan', '~>1.6.10'
gem 'jquery-placeholder-rails'
gem 'activerecord-import'
gem 'html2md'
gem 'mysql2'
gem 'ruby-progressbar'
gem 'rack-throttle'

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'therubyracer'
end

group :development do
  gem 'foreman'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'sham_rack'
  gem 'pry-rails'
  gem 'ruby-prof'
  gem 'unicorn'
end

group :test do
  gem 'bourne', require: false
  gem 'capybara-webkit', '~> 1.0.0'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'guard-spork'
  gem 'rb-inotify', require: false
  gem 'fakeweb'
  gem 'curb'
end
