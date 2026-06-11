class BackfillApprovedEnterpriseAccountStatuses < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL.squish
      UPDATE enterprise_accounts
      SET status = 'approved'
      WHERE status = 'pre_registration'
        AND (applicant_email IS NULL OR applicant_email = '')
        AND id IN (
          SELECT enterprise_account_id
          FROM users
          WHERE enterprise_account_id IS NOT NULL
        )
    SQL
  end

  def down
    # Existing user-linked enterprise accounts were already active before the
    # registration review workflow; do not turn them back into registrations.
  end
end
