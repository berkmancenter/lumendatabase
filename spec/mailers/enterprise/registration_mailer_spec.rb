require 'rails_helper'

describe Enterprise::RegistrationMailer, type: :mailer do
  let(:enterprise_account) do
    create(
      :enterprise_account,
      :credit_card,
      name: 'Example Business',
      company_contact_information: '123 Main St, contact@example.com',
      representative_contact_information: 'Jane Rep, jane@example.com'
    )
  end
  let(:user) do
    create(:user, :enterprise, email: 'rep@example.com', enterprise_account: enterprise_account)
  end

  describe '#admin_notification' do
    before do
      setting = LumenSetting.find_or_initialize_by(key: 'enterprise_registration_admin_emails')
      setting.name = 'Enterprise registration admin emails'
      setting.value = "admin1@example.com, admin2@example.com\nadmin3@example.com"
      setting.save!
    end

    let(:mail) { described_class.admin_notification(enterprise_account, user).deliver_now }

    it 'is delivered to every configured admin (comma and newline separated)' do
      expect(mail.to).to match_array(%w[admin1@example.com admin2@example.com admin3@example.com])
    end

    it 'includes all of the submitted registration information' do
      body = mail.body.encoded

      expect(mail.subject).to include('Example Business')
      expect(body).to include('rep@example.com')
      expect(body).to include('Example Business')
      expect(body).to include('123 Main St, contact@example.com')
      expect(body).to include('Jane Rep, jane@example.com')
      expect(body).to include('Credit card')
      expect(body).to include('pro')
      expect(body).to include(enterprise_account.paid_until.to_fs(:simple))
    end

    it 'is not delivered when no admin addresses are configured' do
      LumenSetting.where(key: 'enterprise_registration_admin_emails').update_all(value: '')

      expect { described_class.admin_notification(enterprise_account, user).deliver_now }
        .not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  describe '#client_confirmation' do
    it 'tells a credit-card client their Pro access is ready and links to enterprise features' do
      account = create(:enterprise_account, :credit_card, plan: 'pro')
      client = create(:user, :enterprise, email: 'cc@example.com', enterprise_account: account)

      mail = described_class.client_confirmation(account, client).deliver_now
      body = mail.body.encoded

      expect(mail.to).to eq(['cc@example.com'])
      expect(body).to include('Credit card')
      expect(body).to match(/Pro access is ready/i)
      expect(body).to include('/enterprise/notices/search')
      expect(body).to include('/enterprise/settings')
    end

    it 'tells an invoice client about next steps and that Pro unlocks after payment' do
      account = create(:enterprise_account, :inactive, :invoice)
      client = create(:user, :enterprise, email: 'inv@example.com', enterprise_account: account)

      mail = described_class.client_confirmation(account, client).deliver_now
      body = mail.body.encoded

      expect(mail.to).to eq(['inv@example.com'])
      expect(body).to include('Invoice')
      expect(body).to match(/invoicing/i)
      expect(body).to match(/unlock/i)
    end
  end

  describe '#renewal_invoice' do
    it 'tells the invoice client their period is ending, the amount due, and links to settings' do
      account = create(:enterprise_account, :invoice, plan: 'pro', name: 'Acme',
                                            paid_until: Time.utc(2026, 7, 1, 12, 0, 0))
      client = create(:user, :enterprise, email: 'inv@example.com', enterprise_account: account)

      mail = described_class.renewal_invoice(account, client).deliver_now
      body = mail.body.encoded

      expect(mail.to).to eq(['inv@example.com'])
      expect(mail.subject).to match(/renewal invoice/i)
      expect(body).to include('Acme')
      expect(body).to include('July 01, 2026')
      expect(body).to include('$500.00')
      expect(body).to include('/enterprise/settings')
      expect(mail.attachments).to be_empty
    end
  end

  describe '#invoice_accepted' do
    it 'tells the client their access is ready, through which date, and how to log in' do
      account = create(:enterprise_account, :inactive, :invoice)
      account.extend_pro_access!
      account.save!
      client = create(:user, :enterprise, email: 'inv@example.com', enterprise_account: account)

      mail = described_class.invoice_accepted(account, client).deliver_now
      body = mail.body.encoded

      expect(mail.to).to eq(['inv@example.com'])
      expect(mail.subject).to match(/ready/i)
      expect(body).to match(/Pro access is now active/i)
      expect(body).to include(account.paid_until.to_fs(:simple))
      expect(body).to include('/users/sign_in')
      expect(body).to include('/enterprise/notices/search')
    end
  end
end
