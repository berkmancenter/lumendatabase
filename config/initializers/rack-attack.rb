# frozen_string_literal: true

class Rack::Attack
  whitelist('allow from localhost') do |req|
    req.localhost?
  end

  whitelist('allow unlimited post requests from API submitters') do |req|
    req.post? && req.submitter?
  end

  whitelist('allow unlimited requests from admins') do |req|
    req.admin?
  end

  throttle('permissioned API limit', limit: 60, period: 1.minute) do |req|
    next unless authenticated?

    Rails.logger.debug "[rack-attack] permissioned api limit ip: #{req.ip}"

    req.discriminator
  end

  # Heavily throttle API users without tokens (but allow for trial exploration).
  throttle('unauthed api limit', limit: 5, period: 24.hours) do |req|
    next if authenticated?

    Rails.logger.debug "[rack-attack] api limit ip: #{req.ip}, req.env['HTTP_ACCEPT']: #{req.env['HTTP_ACCEPT']}, content_type: #{req.content_type}"
    req.ip if req.env['HTTP_ACCEPT'] == 'application/json' || req.env['CONTENT_TYPE'] == 'application/json' || req.path.include?('json')
  end

  # Allow people to hit up to 10 notices in a minute (i.e. do a search and open
  # all results in tabs); that's a normal human usage pattern.
  throttle('unauthed request limit', limit: 10, period: 1.minute) do |req|
    next if authenticated?

    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip if req.path.include? 'notices'
  end

  # But don't let that 10/minute continue indefinitely; that's more like a
  # script.
  throttle('unauthed request limit', limit: 30, period: 1.hour) do |req|
    next if authenticated?

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

class Rack::Attack::Request < ::Rack::Request
  LUMEN_REQ_PARAMS = 'action_dispatch.request.request_parameters'.freeze
  LUMEN_AUTH_TOKEN = 'authentication_token'.freeze
  LUMEN_HEADER = 'HTTP_X_AUTHENTICATION_TOKEN'.freeze

  def localhost?
    ['127.0.0.1', '::1'].include? ip
  end

  def admin?
    return false unless user
    (user.roles.include? Role.admin) || (user.roles.include? Role.super_admin)
  end

  def submitter?
    return false unless user

    user.roles.include? Role.submitter
  end

  def authenticated?
    !!user || special_ip?
  end

  def token
    @token ||= if env.key?(LUMEN_HEADER)
                 Rails.logger.info "[rack-attack] Authentication Token in header: #{env['HTTP_X_AUTHENTICATION_TOKEN']}"
                 env[header]
               elsif params[LUMEN_AUTH_TOKEN].present?
                 Rails.logger.info "[rack-attack] Authentication Token in params: #{params[LUMEN_AUTH_TOKEN]}"
                 params[LUMEN_AUTH_TOKEN]
               elsif post? &&
                     env.key?(LUMEN_REQ_PARAMS) &&
                     env[LUMEN_REQ_PARAMS][LUMEN_AUTH_TOKEN].present?
                 # warn (logs, not user) on deprecated token placement
                 Rails.logger.warn "[rack-attack] Authentication Token in JSON POST data: #{env[LUMEN_REQ_PARAMS][LUMEN_AUTH_TOKEN]}"
                 env[LUMEN_REQ_PARAMS][LUMEN_AUTH_TOKEN]
               else
                 nil
               end
  end

  # Used by the throttle to calculate the number of hits from a distinct
  # entity. Should only be used when authenticated? is true; it is the caller's
  # responsibility to check. This function is here because authenticated users
  # are not guaranteed to be logged in (they may be behind special IPs) but
  # are also not guaranteed to come from a single computer (they may be running
  # processes using auth tokens on multiple computers), so we want to use
  # user ID when present but IP when not.
  # This is used only by the 'permissioned API limit' throttle and thus makes
  # no attempt to be general. If the request object needs to provide
  # discriminators in more cases, this (and its implicit relationship to
  # `authenticated?` need to be reconsidered).
  def discriminator
    user&.id || ip
  end

  private

  def user
    @user ||= user_from_session || user_from_token
  end

  def user_from_session
    User.find(self.session['warden.user.user.key'][0][0])
  rescue ActiveRecord::RecordNotFound  # no user with that ID exists
    nil
  rescue NoMethodError  # [] is not defined on NilClass
    nil
  end

  def user_from_token
    User.find_by_authentication_token(token)
  end

  # IP addresses of known legitimate researchers who might otherwise be
  # caught up in low rate limits.
  def special_ip?
    if defined? WhitelistedIps::IPS
      WhitelistedIps::IPS.map { |iprange| iprange.include? ip }.any?
    else
      false
    end
  end
end
