class SetRequestId
  def initialize(app)
    @app = app
  end

  def call(env)
    Current.request_id = env['action_dispatch.request_id']
    @app.call(env)
  end
end
