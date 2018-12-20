Turnout.configure do |config|
  config.maintenance_pages_path = 'app/views/pages'
  config.default_reason = 'Lumen is temporarily unavailable due to site upgrades.'
  config.default_allowed_paths = ['^/admin/']
end
