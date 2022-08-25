class HandleBadEncodingParameters
  INVALID_CHARACTERS = [
    '\\u0000' # null bytes
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      Rack::Utils.parse_nested_query(env['QUERY_STRING'].to_s)

      input = env['rack.input'].read
      env['rack.input'].rewind
      invalid_characters_regex = Regexp.union(INVALID_CHARACTERS)
      raise Rack::Utils::InvalidParameterError if input.match?(invalid_characters_regex)
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
