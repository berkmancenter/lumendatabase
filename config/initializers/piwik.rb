Piwik = YAML.load_file("#{Rails.root.to_s}/config/piwik.yml")[Rails.env]
Piwik['token_auth'] = ENV['MATOMO_TOKEN_AUTH'] if ENV['MATOMO_TOKEN_AUTH'].present?
Piwik['server_tracking_enabled'] = ActiveModel::Type::Boolean.new.cast(
  ENV.fetch(
    'MATOMO_SERVER_TRACKING_ENABLED',
    Piwik.fetch('server_tracking_enabled', true)
  )
)
