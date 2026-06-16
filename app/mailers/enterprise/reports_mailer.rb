class Enterprise::ReportsMailer < ApplicationMailer
  default template_path: 'enterprise/reports_mailer'

  def report_digest(enterprise_account, starts_at, ends_at)
    @enterprise_account = enterprise_account
    @report = Lumen::Enterprise::NoticeReport.new(
      enterprise_account,
      starts_at: starts_at,
      ends_at: ends_at
    )
    @notices = @report.notices

    attachments[attachment_name] = {
      mime_type: 'application/json',
      content: JSON.pretty_generate(@report.as_json)
    }

    mail(
      to: enterprise_account.report_recipient,
      subject: "Lumen notice report for #{enterprise_account.name}"
    )
  end

  def on_demand_report_ready(enterprise_report)
    @enterprise_report = enterprise_report
    @enterprise_account = enterprise_report.enterprise_account
    @download_url = enterprise_report_url(
      token: enterprise_report.download_token,
      host: Chill::Application.config.site_host
    )

    mail(
      to: enterprise_report.requested_by_email,
      subject: "Your Lumen Enterprise report is ready"
    )
  end

  private

  def attachment_name
    "lumen-enterprise-report-#{Time.current.to_date.iso8601}.json"
  end
end
