module CurbHelpers
  def post_api(path, parameters)
    json = parameters.to_json

    Curl::Easy.http_post("http://#{host}:#{port}#{path}", json) do |curl|
      set_default_headers(curl)

      yield curl if block_given?
    end
  end

  def post_broken_json_to_api_as(path, accepts, broken_json)
    Curl::Easy.http_post("http://#{host}:#{port}#{path}", broken_json) do |curl|
      curl.headers['Accept'] = accepts
      curl.headers['Content-Type'] = 'application/json'
    end
  end

  def with_curb_get_for_json(url, options)
    sleep((ENV['SEARCH_SLEEP'] && ENV['SEARCH_SLEEP'].to_i) || 1)

    curb = Curl::Easy.http_get(
      "http://#{host}:#{port}/#{url}?#{Curl.postalize(options)}"
    ) do |curl|
      set_default_headers(curl)
    end

    yield curb
  end

  private

  def host
    Capybara.current_session.server.host
  end

  def port
    Capybara.current_session.server.port
  end

  def set_default_headers(curl)
    curl.headers['Accept'] = 'application/json'
    curl.headers['Content-Type'] = 'application/json'
  end
end
