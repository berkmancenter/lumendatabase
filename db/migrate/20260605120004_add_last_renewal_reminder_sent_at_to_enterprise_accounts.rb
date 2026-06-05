class AddLastRenewalReminderSentAtToEnterpriseAccounts < ActiveRecord::Migration[7.2]
  def change
    add_column :enterprise_accounts, :last_renewal_reminder_sent_at, :datetime
  end
end
