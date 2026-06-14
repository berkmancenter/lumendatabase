# frozen_string_literal: true

module Lumen::UsageTracking
  class Classifier
    DIMENSION_SETTING_KEYS = {
      credential_status: 'matomo_dimension_credential_status_id',
      auth_method: 'matomo_dimension_auth_method_id',
      surface: 'matomo_dimension_surface_id',
      authenticated_user_email: 'matomo_dimension_authenticated_user_email_id'
    }.freeze

    AUTH_METHODS = {
      anonymous: 'anonymous',
      api_token: 'api token',
      notice_token: 'notice token',
      session: 'session'
    }.freeze

    def initialize(request:, user:, notice: nil, authenticated_from_api_token: false)
      @request = request
      @user = user
      @notice = notice
      @authenticated_from_api_token = authenticated_from_api_token
    end

    def dimensions
      {
        credential_status: credentialed? ? 'credentialed' : 'uncredentialed',
        auth_method: auth_method,
        surface: surface,
        authenticated_user_email: user&.email
      }.compact
    end

    def matomo_dimension_parameters
      dimensions.each_with_object({}) do |(name, value), memo|
        dimension_id = self.class.dimension_id_for(name)
        memo["dimension#{dimension_id}"] = value if dimension_id && value.present?
      end
    end

    def api?
      surface == 'api'
    end

    def self.dimension_id_for(name)
      dimension_ids[name.to_s]
    end

    def self.dimension_ids
      setting_ids = dimension_id_settings
      config_ids = (Piwik['custom_dimensions'] || {}).stringify_keys

      DIMENSION_SETTING_KEYS.each_with_object({}) do |(dimension_name, setting_key), memo|
        dimension_id = setting_ids[setting_key].presence ||
                       config_ids[dimension_name.to_s]

        memo[dimension_name.to_s] = dimension_id.to_i if dimension_id.to_i.positive?
      end
    end

    def self.dimension_id_settings
      LumenSetting
        .where(key: DIMENSION_SETTING_KEYS.values)
        .pluck(:key, :value)
        .to_h
    rescue ActiveRecord::StatementInvalid
      {}
    end

    private

    attr_reader :request, :user, :notice

    def credentialed?
      auth_method != AUTH_METHODS[:anonymous]
    end

    def auth_method
      return AUTH_METHODS[:api_token] if authenticated_from_api_token?
      return AUTH_METHODS[:notice_token] if notice_token?
      return AUTH_METHODS[:session] if user.present?

      AUTH_METHODS[:anonymous]
    end

    def authenticated_from_api_token?
      @authenticated_from_api_token == true
    end

    def notice_token?
      return false if request.params[:access_token].blank?
      return false unless notice

      TokenUrl.valid?(request.params[:access_token], notice)
    end

    def surface
      return 'api' if request.format.json?
      return 'api' if request.path.to_s.end_with?('.json')
      return 'api' if request.get_header('HTTP_ACCEPT').to_s == 'application/json'

      'web'
    end
  end
end
