class CatchJsonParsingErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue MultiJson::LoadError => error
      error_output = "There was a problem in the JSON you submitted: #{error}"
      return [500, { "Content-Type" => "application/json" }, [ error_output.to_json ]]
    end
  end
end
