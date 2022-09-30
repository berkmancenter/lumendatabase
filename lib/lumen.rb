require_relative './lumen_logger'
require 'dotenv/load'

module Lumen
  # Application-wide loggers
  lumen_logger_event_customize = lambda do |event|
    event.remove('path')
    event.remove('host')
    event.remove('@version')
  end

  LOGGER = LumenLogger.init(
    path: "log/#{Rails.env}.log",
    customize_event: lambda do |event|
      event['event_type'] = 'rails_log'
      lumen_logger_event_customize.call(event)
    end
  )

  METRICS_LOGGER = LumenLogger.init(
    path: "log/#{Rails.env}_metrics.log",
    customize_event: lambda do |event|
      event['event_type'] = 'metrics_log'
      event.remove('severity')
      lumen_logger_event_customize.call(event)
    end
  )
end
