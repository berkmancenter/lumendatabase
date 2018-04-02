class Rack::Attack
  # Always allow requests from localhost
  # (blacklist & throttles are skipped)
  whitelist( 'allow from localhost' ) do |req|
     # Requests are allowed if the return value is truthy
    '127.0.0.1' == req.ip
  end

  whitelist( 'allow unlimited requests from API users' ) do |req|
    token = nil

    if req.env.key?( 'HTTP_X_AUTHENTICATION_TOKEN' )
      Rails.logger.info "[rack-attack] Authentication Token in header: #{req.env['HTTP_X_AUTHENTICATION_TOKEN']}"
      token = req.env[ 'HTTP_X_AUTHENTICATION_TOKEN' ]
    elsif req.params[ 'authentication_token' ].present?
      Rails.logger.info "[rack-attack] Authentication Token in params: #{req.params['authentication_token']}"
      token = req.params[ 'authentication_token' ]
    elsif req.post? && req.env.key?( 'action_dispatch.request.request_parameters' ) && req.env[ 'action_dispatch.request.request_parameters' ][ 'authentication_token' ].present?
      # warn on deprecated token placement
      Rails.logger.warn "[rack-attack] Authentication Token in JSON POST data: #{req.env[ 'action_dispatch.request.request_parameters' ][ 'authentication_token' ]}"
      token = req.env[ 'action_dispatch.request.request_parameters' ][ 'authentication_token' ]
    end

    u = User.find_by_authentication_token( token )

    if u.nil?
      Rails.logger.warn "[rack-attack] token: #{token}, user: NOT FOUND" unless token.nil?
      false
    elsif !u.has_role?( Role.researcher ) && !u.has_role?( Role.submitter )
      Rails.logger.warn "[rack-attack] token: #{token}, email: #{u.email}, user: MISSING ROLE"
      false
    else
      Rails.logger.info "[rack-attack] email: #{u.email}, user: OK"
      true
    end
  end

  throttle( 'api limit', limit: 5, period: 24.hours ) do |req|
    Rails.logger.debug "[rack-attack] api limit ip: #{req.ip}, req.env['HTTP_ACCEPT']: #{req.env['HTTP_ACCEPT']}, content_type: #{req.content_type}"
    req.ip if req.env[ 'HTTP_ACCEPT' ] == 'application/json' || req.env[ 'CONTENT_TYPE' ] == 'application/json' || req.path.include?( 'json' )
  end

  throttle('request limit', limit: 200, period: 5.minutes) do |req|
    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip
  end

  self.throttled_response = lambda do |env|
    [ 429,  # status
      { 'Content-Type' => 'text/plain' },   # headers
      [ 'Oops, you were browsing a little faster than we can keep up with. Please wait at least five minutes and try your request again. If you need to make more requests than our limit, please wait five minutes and then visit https://lumendatabase.org/pages/researchers#key to request a research account key.' ]
    ] # body
  end
end

