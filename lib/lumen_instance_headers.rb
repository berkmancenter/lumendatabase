# frozen_string_literal: true

class LumenInstanceHeaders
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    headers['X-Lumen-Instance-Name'] = ENV['LUMEN_INSTANCE_NAME'] if ENV['LUMEN_INSTANCE_NAME'].present?
    headers['X-Lumen-Instance-Pool'] = ENV['LUMEN_INSTANCE_POOL'] if ENV['LUMEN_INSTANCE_POOL'].present?

    [status, headers, body]
  end
end
