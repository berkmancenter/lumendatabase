ENV["RAILS_ENV"] ||= 'test'
require 'rubygems'
require 'spork'

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'

  # https://github.com/sporkrb/spork/issues/188
  ActiveRecord::Base.remove_connection
end

Spork.each_run do
  # https://github.com/sporkrb/spork/issues/188
  ActiveRecord::Base.establish_connection

  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  RSpec.configure do |config|
    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.use_transactional_fixtures = false
    config.infer_base_class_for_anonymous_controllers = false
    config.order = "random"
  end
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.javascript_driver = :chrome
