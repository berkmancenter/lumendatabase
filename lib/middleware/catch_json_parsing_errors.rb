class CatchJsonParsingErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionDispatch::ParamsParser::ParseError => error
    raise error unless env['HTTP_ACCEPT'] =~ %r{application/json}i

    error_output = "There was a problem in the JSON you submitted: #{error}"
    [
      400, { 'Content-Type' => 'application/json' },
      [{ status: 400, error: error_output }.to_json]
    ]
  end
end
