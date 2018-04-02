ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rubygems'
require 'rspec/rails'
require 'capybara/rspec'
require 'curb'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Capybara
  config.include Capybara::DSL

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end
