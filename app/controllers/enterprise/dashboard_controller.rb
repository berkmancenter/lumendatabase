class Enterprise::DashboardController < Enterprise::BaseController
  def show
    @enterprise_account = enterprise_account
    @dashboard = Lumen::Enterprise::Dashboard.new(@enterprise_account)
    @enterprise_domains = @enterprise_account.enterprise_domains.order(:domain)
    @latest_report = @enterprise_account.enterprise_reports.order(created_at: :desc).first
  end
end
