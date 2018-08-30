source 'https://rubygems.org'

# This is not alphabetized. Is that sad? Yes. However, alphabetizing it causes
# the test suite to fail, and tracking down where the dependency is would be
# a pain.

gem 'stackprof'
gem 'skylight'
gem 'bourbon'
gem 'neat'
gem 'flutie'
gem 'high_voltage'
gem 'rails', '~> 4.2.10'
gem 'recipient_interceptor'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'pg', '0.20.0'
gem 'simple_form'
gem 'mime-types', '2.99.3'
gem 'paperclip', '3.5.4'
gem 'active_model_serializers', '~> 0.8.3'
gem 'acts-as-taggable-on'
gem 'ancestry'
gem 'devise'
gem 'rails_admin'
# kaminari is locked because we've monkeypatched it to work around
# slow postgres table counts on large tables.
gem 'kaminari', '0.14.1'
gem 'redcarpet', '~>2.3.0'
gem 'country_select'
gem 'select2-rails', '~> 4.0', '>= 4.0.3'
gem 'bootstrap-datepicker-rails'
#gem 'cancan', '~>1.6.10'
gem 'cancancan'
gem 'jquery-placeholder-rails'
gem 'activerecord-import'
gem 'html2md'
gem 'mysql2'
gem 'ruby-progressbar'
gem 'turnout'
gem 'date_validator'
gem 'twitter'
gem 'twitter-text'
gem 'rails_admin_tag_list'
gem 'rack-attack'
gem 'rack-test', require: 'rack/test'
gem 'minitest'
gem 'spork-rails', git: 'https://github.com/sporkrb/spork-rails'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'coveralls', require: false
gem 'lograge'
gem 'dotenv-rails'

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'uglifier'
  gem 'therubyracer'
end

group :development do
  gem 'foreman'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'phantomjs'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'sham_rack'
  gem 'pry-rails'
  gem 'ruby-prof'
  gem 'rspec-collection_matchers', '~> 1.1', '>= 1.1.2'
  gem 'pry-byebug'
  gem 'pry', '~> 0.10.4'
end

group :test do
  gem 'bourne', require: false
  gem 'poltergeist', '~> 1.10'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'shoulda-matchers', '~> 3.1', '>= 3.1.1'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'fakeweb'
  gem 'curb'
  gem 'elasticsearch-extensions'
end
