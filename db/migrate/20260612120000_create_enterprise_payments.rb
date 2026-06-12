class CreateEnterprisePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :enterprise_payments do |t|
      t.references :enterprise_account, null: false, foreign_key: true
      t.references :user, foreign_key: { on_delete: :nullify }
      t.string :provider, null: false, default: 'stripe'
      t.string :payment_method, null: false, default: 'credit_card'
      t.string :status, null: false, default: 'pending'
      t.integer :amount_cents, null: false
      t.string :currency, null: false, default: 'usd'
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.string :stripe_customer_id
      t.string :stripe_event_id
      t.datetime :period_started_at
      t.datetime :period_ends_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :enterprise_payments, :stripe_checkout_session_id, unique: true
    add_index :enterprise_payments, :stripe_payment_intent_id, unique: true
    add_index :enterprise_payments, :stripe_event_id, unique: true
  end
end
