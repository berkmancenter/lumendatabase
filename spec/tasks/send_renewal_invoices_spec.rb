require 'rails_helper'

describe 'rake enterprise:send_renewal_invoices', type: :task do
  def deliveries_count
    ActionMailer::Base.deliveries.count
  end

  def account_with_user(paid_until:, trait: :invoice, plan: 'pro')
    account = create(:enterprise_account, trait, plan: plan, paid_until: paid_until)
    create(:user, :enterprise, email: 'inv@example.com', enterprise_account: account)
    account
  end

  it 'emails invoice-billed pro accounts one week before expiry and records the reminder' do
    account = account_with_user(paid_until: 7.days.from_now)

    expect { task.execute }.to change { deliveries_count }.by(1)
    expect(account.reload.last_renewal_reminder_sent_at).to be_present
  end

  it 'emails invoice-billed pro accounts one day before expiry' do
    account_with_user(paid_until: 1.day.from_now)

    expect { task.execute }.to change { deliveries_count }.by(1)
  end

  it 'does not email accounts outside the reminder windows' do
    account_with_user(paid_until: 3.days.from_now)

    expect { task.execute }.not_to change { deliveries_count }
  end

  it 'does not email credit-card accounts' do
    account_with_user(paid_until: 7.days.from_now, trait: :credit_card)

    expect { task.execute }.not_to change { deliveries_count }
  end

  it 'does not send twice when run again the same day' do
    account_with_user(paid_until: 7.days.from_now)

    task.execute

    expect { task.execute }.not_to change { deliveries_count }
  end
end
