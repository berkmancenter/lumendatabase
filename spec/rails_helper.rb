ENV['RAILS_ENV'] ||= 'test'

# Prevent things in config/environment from being reloaded if they have
# already been loaded in a previous test. HTTP_ERRORS is chosen at
# random from things initialized in that directory.
unless defined? HTTP_ERRORS
  require File.expand_path('../config/environment', __dir__)
end

# Prevent database truncation if the environment is production
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'rubygems'
require 'rspec/rails'
require 'webmock/rspec'
require 'rspec/mocks'
require 'hasher'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Enables --only-failures.
  config.example_status_persistence_file_path = 'rspec_examples.txt'

  config.before(:each, js: true) do
    # The default window size is too narrow, and may cause elements to overlap
    # (and thus not be clickable) due to inadequately responsive design.
    Capybara.page.driver.browser.manage.window.resize_to(2048, 600)
  end

  config.before(:suite) do
    Rake::Task['lumen:set_up_cms'].execute
  end
end

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # with.test_framework :minitest
    # with.test_framework :minitest_4
    # with.test_framework :test_unit

    # Choose one or more libraries:
    with.library :active_record
    with.library :active_model
    with.library :action_controller
    # Or, choose the following (which implies all of the above):
    # with.library :rails
  end
end

# https://github.com/rspec/rspec-rails/issues/1309
RSpec.configure do |c|
  c.before(:suite) do
    if defined?(::RSpec::Mocks)
      # Need to require the base file to setup internal support require helpers
      require 'rspec/mocks'
      require 'rspec/mocks/test_double'
      ::RSpec::Mocks::TestDouble.module_exec do
        # @private
        def as_json(*args, &block)
          return method_missing(:as_json, *args, &block) unless null_object?
          __mock_proxy.record_message_received(:as_json, *args, &block)
          nil
        end

        # @private
        def to_json(*args, &block)
          return method_missing(:to_json, *args, &block) unless null_object?
          __mock_proxy.record_message_received(:to_json, *args, &block)
          "null"
        end

        # @private
        remove_method(:respond_to?)
        def respond_to?(message, incl_private = false)
          return true if null_object?
          if [:to_json, :as_json].include?(message)
            public_methods(false).include?(message)
          else
            super
          end
        end
      end

      require 'rspec/mocks/verifying_double'
      ::RSpec::Mocks::VerifyingDouble.module_exec do
        # @private
        def as_json(*args, &block)
          verify_on_mock_proxy(:as_json, *args)
          super
        end

        # @private
        def to_json(*args, &block)
          verify_on_mock_proxy(:to_json, *args)
          super
        end

      private

        def verify_on_mock_proxy(message, *args)
          # Null object conditional is an optimization. If not a null object,
          # validity of method expectations will have been checked at
          # definition time.
          return unless null_object?

          if @__sending_message == message
            __mock_proxy.ensure_implemented(message)
          else
            __mock_proxy.ensure_publicly_implemented(message, self)
          end

          __mock_proxy.validate_arguments!(message, args)
        end
      end
    end
  end
end
