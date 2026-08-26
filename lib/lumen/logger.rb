require 'logstash-logger'

class Lumen::Logger
  ERROR_SEVERITIES = %w[ERROR FATAL].freeze

  def self.init(**args)
    file_path = args[:path]

    if ENV['LOG_TO_LOGSTASH_FORMAT']
      path_parts = file_path.split('/')
      aliased_path = path_parts.take(path_parts.length - 1).join('/') + "/logstash_#{path_parts.last}"
      LogStashLogger.new(**args, type: :file, path: aliased_path)
    elsif ENV['RAILS_LOG_TO_STDOUT']
      logger = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = ::Logger::Formatter.new
      ActiveSupport::TaggedLogging.new(logger)
    else
      logger = ActiveSupport::Logger.new(file_path)
      logger.formatter = ::Logger::Formatter.new
      ActiveSupport::TaggedLogging.new(logger)
    end
  end

  def self.log_metrics(action, **data)
    # We want to always log metrics, therefore calling error here.
    Lumen::METRICS_LOGGER.error(action: action, **data, **current_user)
  end

  def self.customize_rails_log_event(event, stack_trace = nil)
    event['event_type'] = 'rails_log'
    return unless ERROR_SEVERITIES.include?(event['severity'])

    stack_trace ||= caller(2)
    event['stack_trace'] = Rails.backtrace_cleaner.clean(stack_trace).join("\n")
  end

  def self.current_user
    user = {}
    if Current.user
      user = {
        user_id: Current.user.id,
        email: Current.user.email
      }
    end
    user
  end
end
