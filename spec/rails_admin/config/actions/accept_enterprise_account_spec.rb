require 'rails_helper'
require 'rails_admin/config/actions/accept_enterprise_account'

describe AcceptEnterpriseAccountProc do
  include RailsAdminActionContext

  before { setup_action_context }

  let(:account) { create(:enterprise_account, :pre_registration, applicant_email: 'rep@example.com') }
  let(:flash_store) { {} }

  context 'GET request' do
    before do
      allow(request).to receive(:get?).and_return(true)
      params[:id] = account.id

      allow(self).to receive(:flash).and_return(flash_store)
      allow(self).to receive(:rails_admin).and_return(
        double('routes', show_path: '/admin', edit_path: '/admin/edit')
      )
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

    it 'redirects back to edit when the applicant email is missing' do
      broken_account = build(:enterprise_account, :pre_registration, applicant_email: nil)
      broken_account.save!(validate: false)
      params[:id] = broken_account.id

      instance_eval(&AcceptEnterpriseAccountProc)

      expect(flash_store[:error]).to include("Applicant email can't be blank")
      expect(self).to have_received(:redirect_to).with('/admin/edit')
      expect(broken_account.reload.status).to eq('pre_registration')
    end
  end
end
