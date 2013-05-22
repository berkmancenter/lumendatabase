source 'https://rubygems.org'

ruby '2.0.0'

gem 'airbrake'
gem 'bourbon'
gem 'neat'
gem 'delayed_job_active_record', '>= 4.0.0.beta2'
gem 'flutie'
gem 'high_voltage'
gem 'jquery-rails'
gem 'pg'
gem 'rack-timeout'
gem 'rails', '>= 3.2.11'
gem 'recipient_interceptor'
gem 'simple_form'
gem 'strong_parameters'
gem 'unicorn'
gem 'paperclip'
gem 'active_model_serializers', '~> 0.8.0'
gem 'acts-as-taggable-on'
gem 'ancestry'

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
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
  gem 'pry'
end

group :test do
  gem 'bourne', require: false
  gem 'capybara-webkit', '>= 0.14.1'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'guard-spork'
  gem 'rb-inotify', require: false
end

group :staging, :production do
  gem 'newrelic_rpm'
end
