namespace :enterprise do
  desc 'Send scheduled enterprise notice reports'
  task send_reports: :environment do
    now = Time.current

    EnterpriseAccount.reporting_enabled.find_each do |enterprise_account|
      next unless enterprise_account.report_due?(now)

      starts_at = enterprise_account.report_period_start(now)

      EnterpriseReportsMailer
        .enterprise_report_digest(enterprise_account, starts_at, now)
        .deliver_later

      enterprise_account.update!(last_report_sent_at: now)
    end
  end
end
