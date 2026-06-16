# frozen_string_literal: true

class ApplicationController < ActionController::Base
  ENTERPRISE_NOTICES_DEFAULT_SORT = 'created_at desc'.freeze

  layout :layout_by_resource
  protect_from_forgery with: :exception

  before_action :authenticate_user_from_token!
  before_action :set_profiler_auth
  before_action :set_current_user

  rescue_from CanCan::AccessDenied do |ex|
    logger.warn "Unauthorized attempt to #{ex.action} #{ex.subject}"

    redirect_to main_app.root_path, alert: ex.message
  end

  skip_before_action :verify_authenticity_token

  after_action :store_action
  after_action :include_auth_cookie
  after_action :track_usage_with_matomo

  helper_method :enterprise_my_notices_path,
                :matomo_tracking_dimensions,
                :matomo_dimension_parameters,
                :matomo_visitor_id

  if Rails.env.staging? || Rails.env.production?
    [
      ActiveRecord::RecordNotFound,
      ActionController::RoutingError,
      ActionController::UnknownFormat,
      ActionController::UnknownHttpMethod,
      ActionController::BadRequest,
      ActionController::InvalidAuthenticityToken,
      ActionController::InvalidCrossOriginRequest,
      ActionController::MethodNotAllowed,
      ActionController::NotImplemented,
      ActionController::ParameterMissing,
      ActionDispatch::Http::MimeNegotiation::InvalidType,
      ActionDispatch::Http::Parameters::ParseError
    ].each do |exception_class|
      rescue_from exception_class do |exception|
        resource_not_found(exception)
      end
    end

    rescue_from Paperclip::AdapterRegistry::NoHandlerError do
      attachment_type_not_allowed
    end
  end

  def routing_error
    resource_not_found
  end

  def after_sign_in_path_for(resource)
    return super unless resource.respond_to?(:enterprise?) && resource.enterprise?
    return enterprise_my_notices_path if resource.active_enterprise_account

    # A confirmed-but-unpaid enterprise user lands on settings, where they can
    # choose a Pro plan and see payment status.
    return enterprise_settings_path if resource.confirmed_enterprise_user?

    root_path
  end

  def enterprise_my_notices_path
    enterprise_notices_search_index_path(sort_by: ENTERPRISE_NOTICES_DEFAULT_SORT)
  end

  def resource_not_found(exception = false)
    logger404s = Lumen::Logger.init(
      path: "log/#{Rails.env}_404s.log",
      customize_event: ->(event) { event['event_type'] = 'rails_log' }
    )

    if exception
      logger404s.error(
        format(
          'Exception %s "%s" for %s at %s',
          request.raw_request_method,
          request.filtered_path,
          request.remote_ip,
          Time.now.to_s
        )
      )
      logger404s.error(exception)
    end

    set_default_format

    respond_to do |format|
      format.html do
        render 'error_pages/404',
               status: :not_found,
               layout: false
      end
      format.json do
        render json: 'Not Found',
               status: :not_found
      end
    end
  end

  def current_ability
    @current_ability ||= Lumen::Ability.new(current_user)
  end

  private

  def layout_by_resource
    if devise_controller?
      'sessions'
    elsif self.class.name.include? 'RailsAdmin'
      'rails_admin/application'
    else
      'application'
    end
  end

  def authenticate_user_from_token!
    @authenticated_from_api_token = false
    @matomo_usage_classifier = nil

    token = authentication_token
    Rails.logger.info "Attempted login from token #{token.to_s}"
    user = token && User.find_by_authentication_token(token.to_s)

    return unless user
    @authenticated_from_api_token = true
    sign_in user, store: false
  end

  def set_profiler_auth
    if current_user&.role? Role.super_admin
      Rack::MiniProfiler.authorize_request
    else
      Rack::MiniProfiler.deauthorize_request
    end
  end

  def authentication_token
    key = 'authentication_token'

    params[key] || request.env["HTTP_X_#{key.upcase}"]
  end

  def include_auth_cookie
    cookies[:lumen_authenticated] = (current_user.present? ? 1 : 0)
  end

  def matomo_tracking_dimensions
    matomo_usage_classifier.dimensions
  end

  def matomo_dimension_parameters
    matomo_usage_classifier.matomo_dimension_parameters
  end

  def track_usage_with_matomo
    return if Piwik['disabled']

    MatomoTrackingJob.perform_later(matomo_tracking_payload)
  end

  def matomo_tracking_payload
    {
      url: "#{request.protocol}#{request.host_with_port}#{request.filtered_path}",
      action_name: "#{controller_path}##{action_name}",
      ua: request.user_agent,
      lang: request.headers['Accept-Language'],
      urlref: request.referer,
      uid: current_user&.email,
      _id: matomo_visitor_id
    }.compact
     .merge(matomo_attribution_parameters)
     .merge(matomo_dimension_parameters)
  end

  # Matomo only honours an overridden visitor IP and action timestamp when a
  # valid API token accompanies the request; without one it would attribute
  # every hit to the application server and use the worker's clock. We therefore
  # send these only when a token is configured, and omit them otherwise rather
  # than ship values Matomo will silently discard.
  def matomo_attribution_parameters
    return {} if Piwik['token_auth'].blank?

    {
      token_auth: Piwik['token_auth'],
      cip: request.remote_ip,
      cdt: Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
    }
  end

  # A stable visitor id lets the server-side pageview and the browser-side link
  # tracking belong to the same Matomo visit. Browsers persist it in a cookie
  # (and the JS tracker is told to reuse it via setVisitorId), while API clients
  # send no cookie, so we derive a deterministic id from the request principal.
  def matomo_visitor_id
    @matomo_visitor_id ||=
      if matomo_usage_classifier.api?
        derived_matomo_visitor_id
      else
        browser_matomo_visitor_id
      end
  end

  def browser_matomo_visitor_id
    existing = cookies[:matomo_visitor_id]
    return existing if existing.present?

    SecureRandom.hex(8).tap do |id|
      cookies[:matomo_visitor_id] = { value: id, expires: 2.years, httponly: true }
    end
  end

  def derived_matomo_visitor_id
    seed = current_user&.id || authentication_token.presence ||
           "#{request.remote_ip}|#{request.user_agent}"

    Digest::SHA256.hexdigest("matomo-visitor-#{seed}")[0, 16]
  end

  def store_action
    skip_paths = ['/users/sign_in', '/users/sign_up', '/users/password/new',
                  '/users/password/edit', '/users/confirmation',
                  '/users/sign_out']

    return if !request.get? || skip_paths.include?(request.path) ||
              request.xhr?

    store_location_for(:user, request.fullpath)
  end

  def attachment_type_not_allowed
    bad_request
  end

  def bad_request
    set_default_format

    respond_to do |format|
      format.html do
        render 'error_pages/400',
               status: :bad_request,
               layout: false
      end
      format.json do
        render json: 'Bad Request',
               status: :bad_request
      end
    end
  end

  def set_current_user
    Current.user = current_user
  end

  def matomo_usage_classifier
    @matomo_usage_classifier ||= Lumen::UsageTracking::Classifier.new(
      request: request,
      user: current_user,
      notice: instance_variable_get(:@notice),
      authenticated_from_api_token: @authenticated_from_api_token
    )
  end

  def set_default_format
    request.format = :json if request.format.instance_of?(Mime::NullType) ||
                              [:html, :json].exclude?(request.format.symbol)
  end
end
