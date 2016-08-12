class ApplicationController < ActionController::Base
  layout :layout_by_resource

  before_filter :authenticate_user_from_token!

  rescue_from CanCan::AccessDenied do |ex|
    logger.warn "Unauthorized attempt to #{ex.action} #{ex.subject}"

    redirect_to main_app.root_path, alert: ex.message
  end

  protect_from_forgery

  private

  def meta_hash_for(results)
    %i(
      current_page next_page offset per_page
      previous_page total_entries total_pages
    ).each_with_object(query_meta(results)) do |attribute, memo|
      memo[attribute] = results.send(attribute)
    end
  end

  def query_meta(results)
    {
      query: {
        term: params[:term]
      }.merge(facet_query_meta(results) || {}),
      facets: results.facets
    }
  end

  def facet_query_meta(results)
    results.facets && results.facets.keys.each_with_object({}) do |facet, memo|
      if params[facet.to_sym].present?
        memo[facet.to_sym] = params[facet.to_sym]
      end
    end
  end

  def layout_by_resource
    if devise_controller?
      "sessions"
    else
      "application"
    end
  end

  def authenticate_user_from_token!
    user = authentication_token && User.find_by_authentication_token(authentication_token.to_s)

    if user
      sign_in user, store: false
    end
  end

  def authentication_token
    key = 'authentication_token'

    params[key] || request.env["HTTP_X_#{key.upcase}"]
  end
end
