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

  describe 'status' do
    it 'only allows known statuses' do
      expect(build(:enterprise_account, :pre_registration)).to be_valid
      expect(build(:enterprise_account, status: 'approved')).to be_valid
      expect(build(:enterprise_account, status: 'rejected')).to be_valid
      expect(build(:enterprise_account, status: 'maybe')).not_to be_valid
    end

    it 'requires applicant email while awaiting registration review' do
      expect(build(:enterprise_account, :pre_registration, applicant_email: nil)).not_to be_valid
      expect(build(:enterprise_account, :pre_registration, applicant_email: 'rep@example.com')).to be_valid
      expect(build(:enterprise_account, status: 'approved', applicant_email: nil)).to be_valid
    end
  end

  describe 'defaults' do
    it 'defaults a new account to the inactive plan' do
      expect(EnterpriseAccount.new.plan).to eq('inactive')
    end

    it 'defaults a new account to the pre_registration status' do
      expect(EnterpriseAccount.new.status).to eq('pre_registration')
    end
  end

  describe '#approve_registration!' do
    let(:account) { create(:enterprise_account, :pre_registration, applicant_email: 'rep@example.com') }

    it 'marks the account approved and creates an unconfirmed enterprise user with a token' do
      allow(Enterprise::RegistrationMailer).to receive(:email_confirmation)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      user = account.approve_registration!

      expect(account.reload.status).to eq('approved')
      expect(user.email).to eq('rep@example.com')
      expect(user.role?(:enterprise)).to be true
      expect(user.enterprise_account).to eq(account)
      expect(user.enterprise_email_confirmed?).to be false
      expect(user.enterprise_email_confirmation_token).to be_present
    end

    it 'emails the user the confirm-email/set-password link' do
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      expect(Enterprise::RegistrationMailer)
        .to receive(:email_confirmation)
        .with(account, an_instance_of(User))
        .and_return(mailer)

      account.approve_registration!
    end

    it 'attaches the enterprise role to an existing user with that email' do
      existing = create(:user, email: 'rep@example.com')
      allow(Enterprise::RegistrationMailer).to receive(:email_confirmation)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      user = account.approve_registration!

      expect(user.id).to eq(existing.id)
      expect(user.reload.role?(:enterprise)).to be true
      expect(user.enterprise_account).to eq(account)
    end

    it 'does not approve a registration without an applicant email' do
      account = build(:enterprise_account, :pre_registration, applicant_email: nil)
      account.save!(validate: false)

      expect { account.approve_registration! }
        .to raise_error(ActiveRecord::RecordInvalid, /Applicant email can't be blank/)

      expect(account.reload.status).to eq('pre_registration')
      expect(account.users.count).to eq(0)
    end
  end

  describe '#reject_registration!' do
    let(:account) { create(:enterprise_account, :pre_registration) }

    it 'marks the account rejected and notifies the applicant' do
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      expect(Enterprise::RegistrationMailer)
        .to receive(:client_rejected).with(account).and_return(mailer)

      account.reject_registration!

      expect(account.reload.status).to eq('rejected')
    end

    it 'does not reject a registration without an applicant email' do
      account = build(:enterprise_account, :pre_registration, applicant_email: nil)
      account.save!(validate: false)

      expect { account.reject_registration! }
        .to raise_error(ActiveRecord::RecordInvalid, /Applicant email can't be blank/)

      expect(account.reload.status).to eq('pre_registration')
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
    it 'does not give report access to inactive accounts' do
      pro_with_reports = create(:enterprise_account, plan: 'pro', report_frequency: 'daily')
      create(:enterprise_account, plan: 'pro', report_frequency: 'none')
      create(:enterprise_account, :inactive, report_frequency: 'daily')

      expect(EnterpriseAccount.reporting_enabled).to eq([pro_with_reports])
    end
  end

  describe '#renewal_reminder_due?' do
    def invoice_pro(paid_until:, **attrs)
      create(:enterprise_account, :invoice, plan: 'pro', paid_until: paid_until, **attrs)
    end

    it 'is due one week and one day before the paid period ends' do
      expect(invoice_pro(paid_until: 7.days.from_now).renewal_reminder_due?).to be true
      expect(invoice_pro(paid_until: 1.day.from_now).renewal_reminder_due?).to be true
    end

    it 'is not due on other days' do
      expect(invoice_pro(paid_until: 3.days.from_now).renewal_reminder_due?).to be false
      expect(invoice_pro(paid_until: 30.days.from_now).renewal_reminder_due?).to be false
    end

    it 'only applies to invoice-billed pro accounts' do
      credit_card = create(:enterprise_account, :credit_card, plan: 'pro', paid_until: 7.days.from_now)
      inactive = create(:enterprise_account, :invoice, plan: 'inactive', paid_until: 7.days.from_now)

      expect(credit_card.renewal_reminder_due?).to be false
      expect(inactive.renewal_reminder_due?).to be false
    end

    it 'does not remind twice the same day but reminds again in a later window' do
      account = invoice_pro(paid_until: 7.days.from_now)

      account.update!(last_renewal_reminder_sent_at: Time.current)
      expect(account.renewal_reminder_due?).to be false

      account.update!(last_renewal_reminder_sent_at: 2.days.ago)
      expect(account.renewal_reminder_due?).to be true
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
