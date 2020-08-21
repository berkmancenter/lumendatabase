Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # The usual setting for this is false, but that can cause the dev server to
  # hang. See https://github.com/rails/rails/issues/27455 .
  config.eager_load = true

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Use mailcatcher, it's dead simple
  config.action_mailer.delivery_method = (ENV['MAILER_DELIVERY_METHOD'] || :test).to_sym
  config.action_mailer.smtp_settings = {
    address: ENV['SMTP_ADDRESS'] || 'localhost',
    port: ENV['SMTP_PORT'] || 1025,
    openssl_verify_mode: ENV['SMTP_VERIFY_MODE'] || 'none'
  }

  config.action_mailer.default_url_options = {
    host:  ENV['SMTP_HOST'] || 'localhost'
  }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.log_level = (ENV['RAILS_LOG_LEVEL'] || :debug).to_sym

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.assets.js_compressor = Uglifier.new(harmony: true)
  config.assets.css_compressor = :sass

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.active_storage.service = :local
end
