class HandleBadEncodingParameters
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)
    rescue Rack::Utils::InvalidParameterError
      return [
        400,
        { 'Content-Type' => 'text/plain' },
        [
          'Bad request'
        ]
      ]
    end

    @app.call(env)
  end
end
