require_relative 'boot'
require_relative '../lib/middleware/catch_json_parsing_errors'

require 'rails/all'
require 'active_storage/engine'


Bundler.require(:default, Rails.env)

module Chill
  class Application < Rails::Application
    # Ensuring that ActiveStorage routes are loaded before Comfy's globbing
    # route. Without this file serving routes are inaccessible.
    config.railties_order = [ActiveStorage::Engine, :main_app, :all]
    #config.load_defaults 5.1

    config.active_record.default_timezone = :utc
    I18n.config.enforce_available_locales = true

    config.generators do |generate|
      generate.test_framework :rspec
      generate.helper false
      generate.stylesheets false
      generate.javascript_engine false
      generate.view_specs false
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce allow mode for mass assignment.
    # This will create an empty list of allowed attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly allow or deny accessible
    # parameters by using an attr_accessible or attr_protected declaration.

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.middleware.use CatchJsonParsingErrors
    config.middleware.use Rack::Attack
    config.middleware.use StackProf::Middleware, enabled: false,
                                                 mode: :cpu,
                                                 interval: 1000,
                                                 save_every: 5,
                                                 path: 'prof'

    config.log_formatter = proc do |severity, datetime, progname, msg|
      timestamp = datetime.strftime '%Y-%m-%d %H:%M:%S (%Z)'
      "#{timestamp} #{severity}: #{progname} #{msg}\n"
    end
    # Configuration settings
    config.x.api_documentation_link = "https://github.com/berkmancenter/lumendatabase/wiki/Lumen-API-Documentation"
    # Mailer settings
    config.default_sender = ENV['DEFAULT_SENDER'] || 'no-reply@example.com'
    config.return_path = ENV['RETURN_PATH'] || 'user@example.com'
    config.site_host = ENV['SITE_HOST'] || 'example.com'
  end
end
