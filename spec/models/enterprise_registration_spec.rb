require 'rails_helper'

describe EnterpriseRegistration, type: :model do
  def valid_attributes(overrides = {})
    {
      email: 'rep@example.com',
      password: 'secretsauce',
      password_confirmation: 'secretsauce',
      company_name: 'Example Business',
      company_contact_information: '123 Main St, contact@example.com',
      representative_contact_information: 'Jane Rep, jane@example.com',
      payment_method: 'invoice'
    }.merge(overrides)
  end

  describe 'validations' do
    it 'requires email, password, company name and a known payment method' do
      registration = described_class.new

      expect(registration).not_to be_valid
      expect(registration.errors.attribute_names).to include(:email, :password, :company_name, :payment_method)
    end

    it 'requires the password confirmation to match' do
      registration = described_class.new(valid_attributes(password_confirmation: 'different'))

      expect(registration).not_to be_valid
      expect(registration.errors[:password_confirmation]).to be_present
    end

    it 'rejects unknown payment methods' do
      registration = described_class.new(valid_attributes(payment_method: 'cash'))

      expect(registration).not_to be_valid
      expect(registration.errors[:payment_method]).to be_present
    end
  end

  describe '#save' do
    context 'with an invoice registration' do
      subject(:registration) { described_class.new(valid_attributes(payment_method: 'invoice')) }

      it 'creates an inactive account and an enterprise user' do
        expect(registration.save).to be true

        account = registration.enterprise_account
        user = registration.user

        expect(account.name).to eq('Example Business')
        expect(account.plan).to eq('inactive')
        expect(account.paid_until).to be_nil
        expect(account.payment_method).to eq('invoice')
        expect(account.company_contact_information).to eq('123 Main St, contact@example.com')
        expect(account.representative_contact_information).to eq('Jane Rep, jane@example.com')

        expect(user.email).to eq('rep@example.com')
        expect(user.enterprise_account).to eq(account)
        expect(user.role?(:enterprise)).to be true
        expect(registration.pro?).to be false
      end
    end

    context 'with a credit card registration' do
      subject(:registration) { described_class.new(valid_attributes(payment_method: 'credit_card')) }

      it 'creates a pro account with a paid period' do
        expect(registration.save).to be true

        account = registration.enterprise_account

        expect(account.plan).to eq('pro')
        expect(account.paid_until).to be_within(1.minute).of(1.month.from_now)
        expect(registration.pro?).to be true
        expect(registration.user.role?(:enterprise)).to be true
      end
    end

    context 'with a duplicate email' do
      before { create(:user, email: 'rep@example.com') }

      subject(:registration) { described_class.new(valid_attributes) }

      it 'fails with a friendly error and creates nothing' do
        expect(registration.save).to be false

        expect(User.count).to eq(1)
        expect(EnterpriseAccount.count).to eq(0)
        expect(registration.errors[:email].join).to match(/taken/i)
      end
    end

    it 'sends admin and client notification emails after a successful commit' do
      registration = described_class.new(valid_attributes)

      admin_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      client_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(Enterprise::RegistrationMailer).to receive(:admin_notification).and_return(admin_double)
      allow(Enterprise::RegistrationMailer).to receive(:client_confirmation).and_return(client_double)

      registration.save

      expect(Enterprise::RegistrationMailer)
        .to have_received(:admin_notification).with(registration.enterprise_account, registration.user)
      expect(Enterprise::RegistrationMailer)
        .to have_received(:client_confirmation).with(registration.enterprise_account, registration.user)
      expect(admin_double).to have_received(:deliver_later)
      expect(client_double).to have_received(:deliver_later)
    end
  end
end
