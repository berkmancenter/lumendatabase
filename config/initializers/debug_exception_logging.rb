ActionDispatch::DebugExceptions.register_interceptor(
  Lumen::Logger.method(:capture_exception_backtrace)
)
