if Rails.env.staging? || Rails.env.production?
  SMTP_SETTINGS = {
    address: ENV['SMTP_ADDRESS'], # example: 'smtp.sendgrid.net'
    enable_starttls_auto: true,
    domain: ENV['SMTP_DOMAIN'], # example: 'this-app.com'
    port: ENV['SMTP_PORT'],
    openssl_verify_mode: 'none'
  } unless defined?(SMTP_SETTINGS)

  Rails.application.config.action_mailer.smtp_settings = SMTP_SETTINGS
end
