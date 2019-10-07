# These two lines must be first.
require 'coveralls'
Coveralls.wear!('rails')
# Uncomment the following line if you'd like to get an HTML-formatted
# coverage report (`coverage/index.html`) when you run tests on localhost.
# SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

ENV['RAILS_ENV'] ||= 'test'

# Prevent things in config/environment from being reloaded if they have
# already been loaded in a previous test. HTTP_ERRORS is chosen at
# random from things initialized in that directory.
unless defined? HTTP_ERRORS
  require File.expand_path('../config/environment', __dir__)
end

require 'rubygems'
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.order = 'random'

  # If you need to see the order your specs are running in (i.e. to debug
  # order-dependent test failures), uncomment the following. But you may find
  # rspec --bisect more useful. (It may also need the --drb flag to work.)
  # config.before :all do
  #  puts "Running #{self.class.description}"
  # end

  config.before :each, cache: true do
    allow(Rails).to receive(:cache).and_return(
      ActiveSupport::Cache::MemoryStore.new
    )
  end

  config.after :each, cache: true do
    allow(Rails).to receive(:cache).and_call_original
  end
end
