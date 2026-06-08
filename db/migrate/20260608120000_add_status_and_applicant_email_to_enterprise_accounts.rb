class AddStatusAndApplicantEmailToEnterpriseAccounts < ActiveRecord::Migration[7.2]
  # The enterprise sign-up is now reviewed: a registration creates an account in
  # pre_registration and an admin accepts or rejects it. applicant_email holds
  # the email submitted at registration so we can reach the applicant before any
  # user exists and create the user on accept.
  #
  # No data backfill: the enterprise feature is not yet deployed, so there are no
  # existing rows to migrate.
  def change
    add_column :enterprise_accounts, :status, :string, null: false, default: 'pre_registration'
    add_column :enterprise_accounts, :applicant_email, :string
  end
end
