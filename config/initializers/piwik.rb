Piwik = YAML.load_file("#{Rails.root.to_s}/config/piwik.yml")[Rails.env]
Piwik['token_auth'] = ENV['MATOMO_TOKEN_AUTH'] if ENV['MATOMO_TOKEN_AUTH'].present?
