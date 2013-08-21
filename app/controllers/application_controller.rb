class ApplicationController < ActionController::Base
  layout :layout_by_resource

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

end
