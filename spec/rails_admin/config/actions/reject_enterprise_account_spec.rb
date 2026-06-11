require 'rails_helper'
require 'rails_admin/config/actions/reject_enterprise_account'

describe RejectEnterpriseAccountProc do
  include RailsAdminActionContext

  before { setup_action_context }

  let(:account) { create(:enterprise_account, :pre_registration) }
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
    end

    it 'rejects the account and notifies the applicant' do
      expect(Enterprise::RegistrationMailer)
        .to receive(:client_rejected)
        .with(an_instance_of(EnterpriseAccount))
        .and_return(instance_double(ActionMailer::MessageDelivery, deliver_later: true))
      expect(self).to receive(:redirect_to)

      instance_eval(&RejectEnterpriseAccountProc)

      expect(account.reload.status).to eq('rejected')
      expect(account.users.count).to eq(0)
    end

    it 'redirects back to edit when the applicant email is missing' do
      broken_account = build(:enterprise_account, :pre_registration, applicant_email: nil)
      broken_account.save!(validate: false)
      params[:id] = broken_account.id

      instance_eval(&RejectEnterpriseAccountProc)

      expect(flash_store[:error]).to include("Applicant email can't be blank")
      expect(self).to have_received(:redirect_to).with('/admin/edit')
      expect(broken_account.reload.status).to eq('pre_registration')
    end
  end
end
