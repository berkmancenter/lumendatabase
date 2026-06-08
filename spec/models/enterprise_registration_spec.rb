require 'rails_helper'

describe EnterpriseRegistration, type: :model do
  def valid_attributes(overrides = {})
    {
      email: 'rep@example.com',
      company_name: 'Example Business',
      company_contact_information: '123 Main St, contact@example.com',
      representative_contact_information: 'Jane Rep, jane@example.com',
      interested_domains: "example.com\nshop.example.com"
    }.merge(overrides)
  end

  describe 'validations' do
    it 'requires email and company name' do
      registration = described_class.new

      expect(registration).not_to be_valid
      expect(registration.errors.attribute_names).to include(:email, :company_name)
    end
  end

  describe '#save' do
    subject(:registration) { described_class.new(valid_attributes) }

    it 'creates a pre_registration account with the submitted data and no user' do
      expect(registration.save).to be true

      account = registration.enterprise_account

      expect(account.name).to eq('Example Business')
      expect(account.status).to eq('pre_registration')
      expect(account.plan).to eq('inactive')
      expect(account.applicant_email).to eq('rep@example.com')
      expect(account.company_contact_information).to eq('123 Main St, contact@example.com')
      expect(account.representative_contact_information).to eq('Jane Rep, jane@example.com')
      expect(account.interested_domains).to eq("example.com\nshop.example.com")
      expect(User.count).to eq(0)
    end

    it 'sends the admin review request and the applicant acknowledgement' do
      admin_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      client_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(Enterprise::RegistrationMailer).to receive(:admin_review_request).and_return(admin_double)
      allow(Enterprise::RegistrationMailer).to receive(:client_registration_received).and_return(client_double)

      registration.save

      expect(Enterprise::RegistrationMailer)
        .to have_received(:admin_review_request).with(registration.enterprise_account)
      expect(Enterprise::RegistrationMailer)
        .to have_received(:client_registration_received).with(registration.enterprise_account)
      expect(admin_double).to have_received(:deliver_later)
      expect(client_double).to have_received(:deliver_later)
    end

    context 'when the company name is missing' do
      it 'fails and creates nothing' do
        registration = described_class.new(valid_attributes(company_name: ''))

        expect(registration.save).to be false
        expect(EnterpriseAccount.count).to eq(0)
        expect(registration.errors[:company_name]).to be_present
      end
    end
  end
end
