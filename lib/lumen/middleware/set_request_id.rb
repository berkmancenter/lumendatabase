class Lumen::Middleware::SetRequestId
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    Current.request_id = env['action_dispatch.request_id']
    Current.request_url = "#{request.base_url}#{request.filtered_path}"
    @app.call(env)
  end
end
