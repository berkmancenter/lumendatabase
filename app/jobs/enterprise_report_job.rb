class EnterpriseReportJob < ApplicationJob
  queue_as :default

  def perform(enterprise_report_id)
    enterprise_report = EnterpriseReport.find(enterprise_report_id)
    generated_report = Lumen::Enterprise::NoticeReport.new(
      enterprise_report.enterprise_account,
      starts_at: enterprise_report.starts_at,
      ends_at: enterprise_report.ends_at
    )

    enterprise_report.attach_json!(
      JSON.pretty_generate(generated_report.as_json)
    )

    Enterprise::ReportsMailer
      .on_demand_report_ready(enterprise_report)
      .deliver_later
  rescue StandardError => e
    enterprise_report&.mark_failed!(e)
    raise
  end
end
