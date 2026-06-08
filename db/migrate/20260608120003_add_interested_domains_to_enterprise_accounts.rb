class AddInterestedDomainsToEnterpriseAccounts < ActiveRecord::Migration[7.2]
  # Free-text list of the domains an applicant says they want to watch, captured
  # at registration to help admins review the request. The verified
  # EnterpriseDomain records are still created later, from settings.
  def change
    add_column :enterprise_accounts, :interested_domains, :text
  end
end
