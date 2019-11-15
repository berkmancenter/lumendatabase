# frozen_string_literal: true
require './lib/rack-attack/request' # defines helpful monkeypatches used here

def throttled_path?(req)
  [
    req.path.include?('notices'),
    req.path.include?('search')
  ].any?
end

def json?(req)
  [
    req.env['HTTP_ACCEPT'] == 'application/json',
    req.env['CONTENT_TYPE'] == 'application/json',
    req.path.include?('json')
  ].any?
end

class Rack::Attack
  safelist('allow from localhost') do |req|
    req.localhost?
  end

  safelist('allow unlimited post requests from API submitters') do |req|
    req.post? && req.submitter?
  end

  safelist('allow unlimited requests from admins') do |req|
    req.admin?
  end

  throttle('permissioned API limit',
           limit: 60,
           period: 1.minute) do |req|
    next unless req.authenticated?

    Rails.logger.debug "[rack-attack] permissioned api limit ip: #{req.ip}"

    req.discriminator if (throttled_path?(req) || json?(req))
  end

  # Heavily throttle API users without tokens (but allow for trial exploration).
  throttle('unauthed api limit',
           limit: 5,
           period: 24.hours) do |req|
    next if req.authenticated?

    Rails.logger.debug "[rack-attack] api limit ip: #{req.ip}, req.env['HTTP_ACCEPT']: #{req.env['HTTP_ACCEPT']}, content_type: #{req.content_type}"
    req.ip if json?(req)
  end

  # Allow people to hit up to 10 notices in a minute (i.e. do a search and open
  # all results in tabs); that's a normal human usage pattern.
  throttle('unauthed request limit per minute',
           limit: 10,
           period: 1.minute) do |req|
    next if req.authenticated?

    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip if throttled_path?(req)
  end

  # But don't let that 10/minute continue indefinitely; that's more like a
  # script.
  throttle('unauthed request limit per hour',
           limit: 30,
           period: 1.hour) do |req|
    next if req.authenticated?

    Rails.logger.debug "[rack-attack] request limit ip: #{req.ip}, content_type: #{req.content_type}"
    req.ip if throttled_path?(req)
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
