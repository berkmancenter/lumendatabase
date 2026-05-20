class CreateEnterpriseAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :enterprise_accounts do |t|
      t.string :name, null: false
      t.boolean :active, null: false, default: true
      t.string :report_frequency, null: false, default: 'none'
      t.string :report_recipient_email
      t.datetime :last_report_sent_at
      t.text :notes

      t.timestamps
    end

    add_reference :users, :enterprise_account, foreign_key: true

    create_table :enterprise_domains do |t|
      t.references :enterprise_account, null: false, foreign_key: true
      t.string :domain, null: false
      t.boolean :verified, null: false, default: false
      t.datetime :verified_at
      t.text :notes

      t.timestamps
    end

    add_index :enterprise_domains, :domain
    add_index :enterprise_domains,
              [:enterprise_account_id, :domain],
              unique: true,
              name: 'index_enterprise_domains_on_account_and_domain'

    Role.find_or_create_by!(name: 'enterprise')
  end
end
