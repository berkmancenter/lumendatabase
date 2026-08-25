class Lumen::Middleware::SetRequestId
  def initialize(app)
    @app = app
  end

  def call(env)
    Current.request_id = env['action_dispatch.request_id']
    Current.request_url = Rack::Request.new(env).url
    @app.call(env)
  end
end
