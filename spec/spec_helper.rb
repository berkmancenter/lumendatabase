# These two lines must be first.
require 'coveralls'
Coveralls.wear!('rails')

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require 'rubygems'
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.order = "random"

  config.before :each, cache: true do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
  end

  config.after :each, cache: true do
    allow(Rails).to receive(:cache).and_call_original
  end
end
