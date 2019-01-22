Turnout.configure do |config|
  config.maintenance_pages_path = Rails.root.join('app', 'views', 'pages')
  config.default_reason = 'Lumen is down for maintenance. It should be back shortly.'
  config.default_allowed_paths = [
    '^/admin',
    # The following are required for the admin to be usable.
    '^/assets/',
    '^/users/sign_in',
    '^/users/sign_out',
    # The following are required to style the maintenance page correctly.
    '^/error_style.css',
    '^/logo_2x.png'
  ]
end
