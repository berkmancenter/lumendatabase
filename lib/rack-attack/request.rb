# Upstream explicitly suggests using this class for monkeypatching:
# https://github.com/kickstarter/rack-attack/blob/master/lib/rack/attack/request.rb .
class Rack::Attack::Request
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
                 env[LUMEN_HEADER]
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
    env['warden'].user
  end

  def user_from_token
    User.find_by_authentication_token(token)
  end

  # IP addresses of known legitimate researchers who might otherwise be
  # caught up in low rate limits.
  def special_ip?
    if defined? AllowedIps::IPS
      AllowedIps::IPS.map { |iprange| iprange.include? ip }.any?
    else
      false
    end
  end
end
