require 'rails_helper'

describe Enterprise::RegistrationMailer, type: :mailer do
  def configure_admin_emails(value = "admin1@example.com, admin2@example.com\nadmin3@example.com")
    setting = LumenSetting.find_or_initialize_by(key: 'enterprise_registration_admin_emails')
    setting.name = 'Enterprise registration admin emails'
    setting.value = value
    setting.save!
  end

  describe '#admin_review_request' do
    let(:account) do
      create(
        :enterprise_account,
        :pre_registration,
        name: 'Example Business',
        applicant_email: 'rep@example.com',
        company_contact_information: '123 Main St, contact@example.com',
        representative_contact_information: 'Jane Rep, jane@example.com',
        interested_domains: "example.com\nshop.example.com"
      )
    end

    before { configure_admin_emails }

    let(:mail) { described_class.admin_review_request(account).deliver_now }

    it 'is delivered to every configured admin (comma and newline separated)' do
      expect(mail.to).to match_array(%w[admin1@example.com admin2@example.com admin3@example.com])
    end

    it 'includes the submitted data and a link to the admin account page' do
      body = mail.body.encoded

      expect(mail.subject).to include('Example Business')
      expect(body).to include('rep@example.com')
      expect(body).to include('123 Main St, contact@example.com')
      expect(body).to include('Jane Rep, jane@example.com')
      expect(body).to include('example.com')
      expect(body).to include('shop.example.com')
      expect(body).to include("/admin/enterprise_account/#{account.id}")
    end

    it 'is not delivered when no admin addresses are configured' do
      LumenSetting.where(key: 'enterprise_registration_admin_emails').update_all(value: '')

      expect { described_class.admin_review_request(account).deliver_now }
        .not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  describe '#client_registration_received' do
    it 'acknowledges the applicant at the registered email' do
      account = create(:enterprise_account, :pre_registration, name: 'Acme', applicant_email: 'rep@example.com')

      mail = described_class.client_registration_received(account).deliver_now

      expect(mail.to).to eq(['rep@example.com'])
      expect(mail.body.encoded).to match(/review/i)
      expect(mail.body.encoded).to include('Acme')
    end
  end

  describe '#client_rejected' do
    it 'tells the applicant their registration was not accepted' do
      account = create(:enterprise_account, :rejected, name: 'Acme', applicant_email: 'rep@example.com')

      mail = described_class.client_rejected(account).deliver_now

      expect(mail.to).to eq(['rep@example.com'])
      expect(mail.body.encoded).to match(/not able to accept|sorry/i)
    end
  end

  describe '#email_confirmation' do
    it 'links the user to the confirm-email/set-password page with their token' do
      account = create(:enterprise_account, :inactive, name: 'Acme')
      user = create(:user, :enterprise, :unconfirmed_enterprise_email,
                    email: 'rep@example.com', enterprise_account: account)

      mail = described_class.email_confirmation(account, user).deliver_now

      expect(mail.to).to eq(['rep@example.com'])
      expect(mail.body.encoded).to include('/enterprise/confirm_email')
      expect(mail.body.encoded).to include(user.enterprise_email_confirmation_token)
    end
  end

  describe '#admin_email_confirmed' do
    before { configure_admin_emails }

    it 'notifies admins that the user confirmed their email' do
      account = create(:enterprise_account, :inactive, name: 'Acme')
      user = create(:user, :enterprise, email: 'rep@example.com', enterprise_account: account)

      mail = described_class.admin_email_confirmed(account, user).deliver_now

      expect(mail.to).to match_array(%w[admin1@example.com admin2@example.com admin3@example.com])
      expect(mail.subject).to include('Acme')
      expect(mail.body.encoded).to include('rep@example.com')
      expect(mail.body.encoded).to include("/admin/enterprise_account/#{account.id}")
    end
  end

  describe '#admin_payment' do
    before { configure_admin_emails }

    it 'notifies admins of a payment with the chosen method and plan' do
      account = create(:enterprise_account, :credit_card, plan: 'pro', name: 'Acme')
      user = create(:user, :enterprise, email: 'rep@example.com', enterprise_account: account)

      mail = described_class.admin_payment(account, user).deliver_now

      expect(mail.to).to match_array(%w[admin1@example.com admin2@example.com admin3@example.com])
      expect(mail.subject).to include('Acme')
      expect(mail.body.encoded).to include('Credit card')
      expect(mail.body.encoded).to include('pro')
    end
  end

  describe '#client_confirmation' do
    it 'tells a credit-card client their Pro access is ready and links to enterprise features' do
      account = create(:enterprise_account, :credit_card, plan: 'pro')
      client = create(:user, :enterprise, email: 'cc@example.com', enterprise_account: account)

      mail = described_class.client_confirmation(account, client).deliver_now
      body = mail.body.encoded

      expect(mail.to).to eq(['cc@example.com'])
      expect(body).to match(/Pro access is ready/i)
      expect(body).to include('/enterprise/notices/search')
      expect(body).to include('/enterprise/settings')
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
