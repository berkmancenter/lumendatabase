class AddEnterpriseEmailConfirmationToUsers < ActiveRecord::Migration[7.2]
  # Enterprise users must confirm the email they registered with (and set a
  # password) before they can sign in and use the account. We store a single-use
  # token and the confirmation timestamp; this is intentionally separate from
  # Devise :confirmable so it stays scoped to enterprise sign-ups and does not
  # affect admin-created users.
  #
  # No data backfill: the enterprise feature is not yet deployed.
  def change
    add_column :users, :enterprise_email_confirmation_token, :string
    add_column :users, :enterprise_email_confirmed_at, :datetime
    add_index :users, :enterprise_email_confirmation_token, unique: true
  end
end
