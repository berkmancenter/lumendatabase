class Rack::Attack
  # Always allow requests from localhost
  # (blacklist & throttles are skipped)
  whitelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy.
    ['127.0.0.1', '::1'].include? req.ip
  end

  whitelist('allow unlimited requests from API users') do |req|
    token = nil

    req_params = 'action_dispatch.request.request_parameters'.freeze
    auth_token = 'authentication_token'.freeze

    if req.env.key?('HTTP_X_AUTHENTICATION_TOKEN')
      Rails.logger.info "[rack-attack] Authentication Token in header: #{req.env['HTTP_X_AUTHENTICATION_TOKEN']}"
      token = req.env['HTTP_X_AUTHENTICATION_TOKEN']
    elsif req.params[auth_token].present?
      Rails.logger.info "[rack-attack] Authentication Token in params: #{req.params[auth_token]}"
      token = req.params[auth_token]
    elsif req.post? &&
          req.env.key?(req_params) &&
          req.env[req_params][auth_token].present?
      # warn on deprecated token placement
      Rails.logger.warn "[rack-attack] Authentication Token in JSON POST data: #{req.env[req_params][auth_token]}"
      token = req.env[req_params][auth_token]
    end

    u = User.find_by_authentication_token(token)

    if u.nil?
      Rails.logger.warn "[rack-attack] token: #{token}, user: NOT FOUND" unless token.nil?
      false
    elsif !u.has_role?(Role.researcher) && !u.has_role?(Role.submitter)
      Rails.logger.warn "[rack-attack] token: #{token}, email: #{u.email}, user: MISSING ROLE"
      false
    else
      Rails.logger.info "[rack-attack] email: #{u.email}, user: OK"
      true
    end
  end

  throttle('api limit', limit: 5, period: 24.hours) do |req|
    Rails.logger.debug "[rack-attack] api limit ip: #{req.ip}, req.env['HTTP_ACCEPT']: #{req.env['HTTP_ACCEPT']}, content_type: #{req.content_type}"
    req.ip if req.env['HTTP_ACCEPT'] == 'application/json' || req.env['CONTENT_TYPE'] == 'application/json' || req.path.include?('json')
  end

  throttle('request limit', limit: 6, period: 1.minute) do |req|
    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip
  end

  throttle('request limit', limit: 15, period: 10.minutes) do |req|
    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip
  end

  # After 3 blocked requests in 10 minutes, block all requests from that IP for
  # a week.
  Rack::Attack.blacklist('bot farms') do |req|
    Rack::Attack::Fail2Ban.filter("botfarm-#{req.ip}",
                                  maxretry: 3,
                                  findtime: 10.minutes,
                                  bantime: 1.week) do
      # The count for the IP is incremented if the return value is truthy. Bots
      # hit all over the site, so we actually just want to count them every
      # time.
      true
    end
  end
  self.throttled_response = lambda do |_env|
    [
      429, # status
      { 'Content-Type' => 'text/plain' }, # headers
      ['Oops, you were browsing a little faster than we can keep up with. Please wait at least five minutes and try your request again. If you need to make more requests than our limit, please wait five minutes and then visit https://lumendatabase.org/pages/researchers#key to request a research account key.']
    ] # body
  end
end
