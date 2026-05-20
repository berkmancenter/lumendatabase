class Client::Notices::SearchController < Notices::SearchController
  before_action :authenticate_user!
  before_action :require_enterprise_account!

  private

  def set_model_specific_variables
    super

    @search_index_path = client_notices_search_index_path
    @facet_search_index_path = facet_client_notices_search_index_path
    @search_all_placeholder = 'Search your domain notices...'
  end

  def configure_searcher(searcher)
    searcher.restrict_to_enterprise_domains(enterprise_account.verified_domain_names)
  end

  def require_enterprise_account!
    return if current_user&.active_enterprise_account

    redirect_to root_path, alert: 'Client access is not active for this account.'
  end

  def enterprise_account
    @enterprise_account ||= current_user.active_enterprise_account
  end
end
