class Loggy
  def initialize(prefix, output_too = false, only_output = false, custom_log_path = false)
    @prefix = prefix
    @output_too = output_too
    @only_output = only_output
    @logger_object = if custom_log_path
                       LogStashLogger.new(
                         type: :file,
                         path: "logstash_#{custom_log_path}.log"
                       )
                     else
                       Rails.logger
                     end
  end

  def info(message)
    log message, 'info'
  end

  def warn(message)
    log message, 'warn'
  end

  def error(message)
    log message, 'error'
  end

  def log(message, level)
    puts full_message(message) if @output_too

    decorated_logger_message = logger_message(message)
    @logger_object.send(level.to_sym, decorated_logger_message) unless @only_output
  end

  def logger_message(message)
    '[' +
      @prefix +
      '] ' +
      message
  end

  def full_message(message)
    '[' +
      Time.now.to_s + +
      ' ' +
      @prefix +
      '] ' +
      message
  end
end
