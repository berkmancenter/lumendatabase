# frozen_string_literal: true

class ApplicationController < ActionController::Base
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

  def resource_not_found(exception = false)
    logger404s = LumenLogger.init(
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
          Time.now.to_default_s
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

  private

  def layout_by_resource
    if devise_controller?
      'sessions'
    else
      'application'
    end
  end

  def authenticate_user_from_token!
    Rails.logger.info "Attempted login from token #{authentication_token.to_s}"
    user = authentication_token &&
           User.find_by_authentication_token(authentication_token.to_s)

    return unless user
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

  def set_default_format
    request.format = :json if request.format.instance_of?(Mime::NullType) ||
                              [:html, :json].exclude?(request.format.symbol)
  end
end
