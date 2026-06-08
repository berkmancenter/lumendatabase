require 'rails_helper'
require 'rails_admin/config/actions/accept_enterprise_account'

describe AcceptEnterpriseAccountProc do
  include RailsAdminActionContext

  before { setup_action_context }

  let(:account) { create(:enterprise_account, :pre_registration, applicant_email: 'rep@example.com') }

  context 'GET request' do
    before do
      allow(request).to receive(:get?).and_return(true)
      params[:id] = account.id

      allow(self).to receive(:flash).and_return({})
      allow(self).to receive(:rails_admin).and_return(double('routes', show_path: '/admin'))
      allow(self).to receive(:redirect_to)
      allow(Enterprise::RegistrationMailer).to receive(:email_confirmation)
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
    end

    it 'approves the account and creates the enterprise user' do
      instance_eval(&AcceptEnterpriseAccountProc)

      account.reload
      expect(account.status).to eq('approved')
      expect(account.users.count).to eq(1)
      expect(account.users.first.role?(:enterprise)).to be true
    end

    it 'emails the confirm-email link and redirects to the account page' do
      expect(Enterprise::RegistrationMailer)
        .to receive(:email_confirmation)
        .with(an_instance_of(EnterpriseAccount), an_instance_of(User))
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
      expect(self).to receive(:redirect_to)

      instance_eval(&AcceptEnterpriseAccountProc)
    end
  end
end
