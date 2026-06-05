require 'rails_helper'
require 'rails_admin/config/actions/accept_invoice'

describe AcceptInvoiceProc do
  include RailsAdminActionContext

  before { setup_action_context }

  let(:account) { create(:enterprise_account, :inactive, :invoice) }
  let!(:user) do
    create(:user, :enterprise, email: 'rep@example.com', enterprise_account: account)
  end

  context 'GET request' do
    before do
      allow(request).to receive(:get?).and_return(true)
      params[:id] = account.id

      allow(self).to receive(:flash).and_return({})
      allow(self).to receive(:rails_admin).and_return(double('routes', show_path: '/admin'))
      allow(self).to receive(:redirect_to)
    end

    it 'activates the account and extends paid access by one month' do
      allow(Enterprise::RegistrationMailer).to receive(:invoice_accepted)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))

      instance_eval(&AcceptInvoiceProc)

      account.reload
      expect(account.plan).to eq('pro')
      expect(account.paid_until).to be_within(1.minute).of(1.month.from_now)
    end

    it 'emails the account client and redirects to the account page' do
      mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      expect(Enterprise::RegistrationMailer)
        .to receive(:invoice_accepted)
        .with(an_instance_of(EnterpriseAccount), user)
        .and_return(mailer)
      expect(mailer).to receive(:deliver_later)
      expect(self).to receive(:redirect_to)

      instance_eval(&AcceptInvoiceProc)
    end
  end
end
