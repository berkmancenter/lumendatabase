Turnout.configure do |config|
  config.maintenance_pages_path = 'app/views/pages'
  config.default_reason = 'Lumen is temporarily unavailable due to site upgrades.'
  config.default_allowed_paths = [
    '^/admin',
    # The following are required for the admin to be usable.
    '^/assets/',
    '^/users/sign_in',
    '^/users/sign_out',
    # The following are required to style the maintenance page correctly.
    '^/error_style.css',
    '^/assets/logo_2x.png'
  ]
end
