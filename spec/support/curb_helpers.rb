module CurbHelpers
  def with_curb_get_for_json(url, options)
    host = Capybara.current_session.server.host
    port = Capybara.current_session.server.port
    curb = Curl.get("http://#{host}:#{port}/#{url}",options) do |curl|
      curl.headers['Accept'] = 'application/json'
    curl.headers['Content-Type'] = 'application/json'
    end
    yield curb
  end

  def with_curb_post_for_json(url, json)
    host = Capybara.current_session.server.host
    port = Capybara.current_session.server.port
    curb = Curl.post("http://#{host}:#{port}/#{url}", json) do |curl|
      curl.headers['Accept'] = 'application/json'
    curl.headers['Content-Type'] = 'application/json'
    end
    yield curb
  end

end
