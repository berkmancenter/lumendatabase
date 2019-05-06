# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout :layout_by_resource

  before_filter :authenticate_user_from_token!
  before_filter :set_profiler_auth

  rescue_from CanCan::AccessDenied do |ex|
    logger.warn "Unauthorized attempt to #{ex.action} #{ex.subject}"

    redirect_to main_app.root_path, alert: ex.message
  end

  skip_before_action :verify_authenticity_token

  after_filter :store_action
  after_action :include_auth_cookie

  if Rails.env.staging? || Rails.env.production?
    rescue_from ActiveRecord::RecordNotFound do |exception|
      resource_not_found(exception)
    end
  end

  private

  def meta_hash_for(results)
    %i[
      current_page next_page offset per_page
      previous_page total_entries total_pages
    ].each_with_object(query_meta(results)) do |attribute, memo|
      begin
        memo[attribute] = results.send(attribute)
      rescue
        memo[attribute] = nil
      end
    end
  end

  def query_meta(results)
    {
      query: {
        term: params[:term]
      }.merge(facet_query_meta(results) || {}),
      facets: results.response.aggregations
    }
  end

  def facet_query_meta(results)
    results.response.aggregations && results.response.aggregations.keys.each_with_object({}) do |facet, memo|
      memo[facet.to_sym] = params[facet.to_sym] if params[facet.to_sym].present?
    end
  end

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

  def resource_not_found(exception)
    logger.error(exception)

    respond_to do |format|
      format.html do
        render file: 'public/404',
               status: :not_found,
               layout: false
      end
      format.json do
        render json: 'Not Found',
               status: :not_found
      end
    end
  end
end
