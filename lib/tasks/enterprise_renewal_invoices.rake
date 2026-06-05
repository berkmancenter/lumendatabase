namespace :enterprise do
  desc 'Email renewal invoices to invoice-billed Pro accounts one week and one day before expiry'
  task send_renewal_invoices: :environment do
    now = Time.current

    EnterpriseAccount.renewal_invoice_candidates.find_each do |enterprise_account|
      next unless enterprise_account.renewal_reminder_due?(now)

      recipient = enterprise_account.users.order(:id).first
      next if recipient.nil?

      Enterprise::RegistrationMailer
        .renewal_invoice(enterprise_account, recipient)
        .deliver_later

      enterprise_account.update!(last_renewal_reminder_sent_at: now)
    end
  end
end
