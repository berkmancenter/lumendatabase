# frozen_string_literal: true

class Rack::Attack
  # Always allow requests from localhost
  # (blacklist & throttles are skipped)
  whitelist('allow from localhost') do |req|
    # Requests are allowed if the return value is truthy.
    ['127.0.0.1', '::1'].include? req.ip
  end

  whitelist('allow from special IPs') do |req|
    # IP addresses of known legitimate researchers who might otherwise be
    # caught up in rate limits.
    if defined? WhitelistedIps::IPS
      WhitelistedIps::IPS.map { |iprange| iprange.include? req.ip }.any?
    else
      false
    end
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
    elsif !u.role?(Role.researcher) && !u.role?(Role.submitter)
      Rails.logger.warn "[rack-attack] token: #{token}, email: #{u.email}, user: MISSING ROLE"
      false
    else
      Rails.logger.info "[rack-attack] email: #{u.email}, user: OK"
      true
    end
  end

  # This logic prevents rackattack from throttling web requests from
  # researchers and admins. They may still be throttled by the proxy for
  # excessive use, as the proxy does not know that they are logged in.
  whitelist('allow unlimited requests from permissioned users') do |req|
    u = user_from_request(req)
    if u.nil?
      false
    elsif (u.roles & [Role.researcher, Role.admin, Role.super_admin]).present?
      true
    else
      false
    end
  end

  throttle('api limit', limit: 5, period: 24.hours) do |req|
    Rails.logger.debug "[rack-attack] api limit ip: #{req.ip}, req.env['HTTP_ACCEPT']: #{req.env['HTTP_ACCEPT']}, content_type: #{req.content_type}"
    req.ip if req.env['HTTP_ACCEPT'] == 'application/json' || req.env['CONTENT_TYPE'] == 'application/json' || req.path.include?('json')
  end

  throttle('request limit', limit: 10, period: 1.minute) do |req|
    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip if req.path.include? 'notices'
  end

  throttle('request limit', limit: 30, period: 1.hour) do |req|
    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip if req.path.include? 'notices'
  end

  self.throttled_response = lambda do |_env|
    Rails.logger.warn "[rack-attack] 429 issued for #{_env['rack.attack.match_discriminator']}"
    [
      429, # status
      { 'Content-Type' => 'text/plain' }, # headers
      ['Oops, you were browsing a little faster than we can keep up with. Please wait at least five minutes and try your request again. If you need to make more requests than our limit, please wait five minutes and then visit https://lumendatabase.org/pages/researchers#key to request a research account key.']
    ] # body
  end
end

def user_from_request(req)
  User.find(req.session['warden.user.user.key'][0][0])
rescue ActiveRecord::RecordNotFound  # no user with that ID exists
  nil
rescue NoMethodError  # [] is not defined on NilClass
  nil
end
