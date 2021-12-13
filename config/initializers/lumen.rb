Rails.application.config.to_prepare do
  module Lumen
    REDACTION_MASK = '[REDACTED]'.freeze
    UNKNOWN_WORK = Work.unknown rescue nil
    SETTINGS = LumenSetting.all rescue nil
    TRUNCATION_TOKEN_URLS_ACTIVE_PERIOD = 24.hours
  end
end
