class LumenLogger
  def self.init(**args)
    file_path = args[:path]

    if ENV['LOG_TO_LOGSTASH_FORMAT']
      path_parts = file_path.split('/')
      aliased_path = path_parts.take(path_parts.length - 1).join('/') + "/logstash_#{path_parts.last}"
      LogStashLogger.new(**args, type: :file, path: aliased_path)
    elsif ENV['RAILS_LOG_TO_STDOUT']
      logger           = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = config.log_formatter
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
    else
      logger = ActiveSupport::Logger.new(file_path)
      logger.formatter = ::Logger::Formatter.new
      ActiveSupport::TaggedLogging.new(logger)
    end
  end
end
