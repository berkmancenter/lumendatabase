# frozen_string_literal: true

require 'rails_helper'

describe Lumen::Enterprise::PaymentMethods::Invoice do
  let(:account) { create(:enterprise_account, :inactive) }
  let(:user) { create(:user, :enterprise, enterprise_account: account) }
  let(:urls) do
    {
      success_url: 'https://example.com/success',
      cancel_url: 'https://example.com/cancel',
      settings_path: '/enterprise/settings',
      status_path: '/enterprise/status'
    }
  end

  subject(:payment_method) do
    described_class.new(enterprise_account: account, user: user, urls: urls)
  end

  before do
    allow(Enterprise::RegistrationMailer).to receive(:admin_payment)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
  end

  it 'records invoice as the account payment method and notifies admins' do
    result = payment_method.start

    expect(account.reload.payment_method).to eq('invoice')
    expect(Enterprise::RegistrationMailer).to have_received(:admin_payment).with(account, user)
    expect(result.redirect_to).to eq('/enterprise/settings')
    expect(result.notice).to match(/invoicing/)
  end

  it 'requires pending payments to be canceled first' do
    create(:enterprise_payment, enterprise_account: account, user: user)

    result = payment_method.start

    expect(account.reload.payment_method).to be_nil
    expect(Enterprise::RegistrationMailer).not_to have_received(:admin_payment)
    expect(result.redirect_to).to eq('/enterprise/status')
    expect(result.alert).to match(/Cancel your pending card payment/)
  end
end
