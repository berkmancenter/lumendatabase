class CreateEnterpriseReports < ActiveRecord::Migration[7.2]
  def change
    create_table :enterprise_reports do |t|
      t.references :enterprise_account, null: false, foreign_key: true
      t.references :requested_by,
                   foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :requested_by_email, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :status, default: 'pending', null: false
      t.string :download_token, null: false
      t.datetime :completed_at
      t.datetime :failed_at
      t.text :failure_message

      t.timestamps
    end

    add_index :enterprise_reports, :download_token, unique: true
    add_index :enterprise_reports, [:enterprise_account_id, :created_at]
    add_index :enterprise_reports, :status
  end
end
