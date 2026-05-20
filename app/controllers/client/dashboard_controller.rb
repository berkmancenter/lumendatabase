class Client::DashboardController < Client::BaseController
  layout 'home'

  def index
    @enterprise_account = enterprise_account
    @verified_domains = @enterprise_account.verified_domains.order(:domain)
    @recent_notices = EnterpriseNoticeReport.recent(@enterprise_account)
    @search_index_path = client_notices_search_index_path
    @search_all_placeholder = 'Search your domain notices...'
  end
end
