class ReplaceActiveWithPlanOnEnterpriseAccounts < ActiveRecord::Migration[7.2]
  def up
    add_column :enterprise_accounts, :plan, :string, null: false, default: 'inactive'
    add_column :enterprise_accounts, :paid_until, :datetime
    add_column :enterprise_accounts, :company_contact_information, :text
    add_column :enterprise_accounts, :representative_contact_information, :text
    add_column :enterprise_accounts, :payment_method, :string

    # Backfill the new plan from the legacy active flag:
    #   active accounts become pro, everything else stays inactive.
    execute "UPDATE enterprise_accounts SET plan = 'pro' WHERE active = TRUE"
    execute "UPDATE enterprise_accounts SET plan = 'inactive' WHERE active = FALSE"

    remove_column :enterprise_accounts, :active
  end

  def down
    add_column :enterprise_accounts, :active, :boolean, null: false, default: true

    execute "UPDATE enterprise_accounts SET active = (plan = 'pro')"

    remove_column :enterprise_accounts, :payment_method
    remove_column :enterprise_accounts, :representative_contact_information
    remove_column :enterprise_accounts, :company_contact_information
    remove_column :enterprise_accounts, :paid_until
    remove_column :enterprise_accounts, :plan
  end
end
