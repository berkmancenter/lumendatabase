Lumen.const_set :SETTINGS, LumenSetting.all rescue nil
Lumen.const_set :UNKNOWN_WORK, Work.unknown rescue nil
Lumen.const_set :TRUNCATION_TOKEN_URLS_ACTIVE_PERIOD, 24.hours
Lumen.const_set :REDACTION_MASK, '[REDACTED]'.freeze
