class Enterprise::ReportsMailer < ApplicationMailer
  default template_path: 'enterprise/reports_mailer'

  def report_digest(enterprise_account, starts_at, ends_at)
    @enterprise_account = enterprise_account
    @report = EnterpriseNoticeReport.new(
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

  private

  def attachment_name
    "lumen-enterprise-report-#{Time.current.to_date.iso8601}.json"
  end
end
