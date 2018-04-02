if Rails.env.staging? || Rails.env.production?
  SMTP_SETTINGS = {
    address: ENV['SMTP_ADDRESS'], # example: 'smtp.sendgrid.net'
    authentication: :plain,
    enable_starttls_auto: false,
    domain: ENV['SMTP_DOMAIN'], # example: 'this-app.com'
    password: ENV['SMTP_PASSWORD'],
    port: ENV['SMTP_PORT'],
    user_name: ENV['SMTP_USERNAME']
  } unless defined?( SMTP_SETTINGS )
end
