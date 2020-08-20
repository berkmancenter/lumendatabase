class Loggy
  def initialize(prefix, output_too = false)
    @prefix = prefix
    @output_too = output_too
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
    Rails.logger.send(level.to_sym, decorated_logger_message)
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
