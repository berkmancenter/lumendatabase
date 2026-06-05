require 'rails_helper'

describe EnterpriseAccount, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:plan) }

    it 'only allows known plans' do
      expect(build(:enterprise_account, plan: 'pro')).to be_valid
      expect(build(:enterprise_account, plan: 'inactive')).to be_valid
      expect(build(:enterprise_account, plan: 'gold')).not_to be_valid
    end

    it 'only allows known payment methods but lets them be blank' do
      expect(build(:enterprise_account, payment_method: 'credit_card')).to be_valid
      expect(build(:enterprise_account, payment_method: 'invoice')).to be_valid
      expect(build(:enterprise_account, payment_method: nil)).to be_valid
      expect(build(:enterprise_account, payment_method: 'cash')).not_to be_valid
    end
  end

  describe 'defaults' do
    it 'defaults a new account to the inactive plan' do
      expect(EnterpriseAccount.new.plan).to eq('inactive')
    end
  end

  describe '#pro?' do
    it 'is true only for the pro plan' do
      expect(build(:enterprise_account, plan: 'pro').pro?).to be true
      expect(build(:enterprise_account, plan: 'inactive').pro?).to be false
    end
  end

  describe '#payment_method_label' do
    it 'returns a human label for the stored payment method' do
      expect(build(:enterprise_account, payment_method: 'credit_card').payment_method_label)
        .to eq('Credit card')
      expect(build(:enterprise_account, payment_method: 'invoice').payment_method_label)
        .to eq('Invoice')
    end
  end

  describe '#extend_pro_access!' do
    it 'promotes the account to pro and sets paid_until one month out' do
      account = build(:enterprise_account, plan: 'inactive', paid_until: nil)

      account.extend_pro_access!

      expect(account.plan).to eq('pro')
      expect(account.paid_until).to be_within(1.minute).of(1.month.from_now)
    end

    it 'extends an existing future paid period rather than overwriting it' do
      future = 2.months.from_now
      account = build(:enterprise_account, plan: 'pro', paid_until: future)

      account.extend_pro_access!

      expect(account.paid_until).to be_within(1.minute).of(future + 1.month)
    end
  end

  describe '#report_due?' do
    it 'is false for inactive accounts even when reporting is configured' do
      account = create(
        :enterprise_account,
        :inactive,
        report_frequency: 'daily',
        report_recipient_email: 'reports@example.com'
      )

      expect(account.report_due?).to be false
    end

    it 'is true for a pro account that is due' do
      account = create(
        :enterprise_account,
        plan: 'pro',
        report_frequency: 'daily',
        report_recipient_email: 'reports@example.com'
      )

      expect(account.report_due?).to be true
    end
  end

  describe '.reporting_enabled' do
    it 'only includes pro accounts with reporting turned on' do
      pro_with_reports = create(:enterprise_account, plan: 'pro', report_frequency: 'daily')
      create(:enterprise_account, plan: 'pro', report_frequency: 'none')
      create(:enterprise_account, :inactive, report_frequency: 'daily')

      expect(EnterpriseAccount.reporting_enabled).to eq([pro_with_reports])
    end
  end

  describe 'destroying an account' do
    it 'detaches its users instead of deleting them or raising a foreign key error' do
      account = create(:enterprise_account)
      user = create(:user, :enterprise, enterprise_account: account)

      expect { account.destroy! }.not_to raise_error

      expect(User.exists?(user.id)).to be true
      expect(user.reload.enterprise_account_id).to be_nil
    end
  end
end
