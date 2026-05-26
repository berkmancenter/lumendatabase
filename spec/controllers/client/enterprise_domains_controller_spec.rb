require 'rails_helper'

describe Client::EnterpriseDomainsController do
  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) { create(:user, :enterprise, enterprise_account: enterprise_account) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#create' do
    it 'adds an unverified domain for the current client' do
      post :create, params: { enterprise_domain: { domain: 'https://Example.com/path' } }

      enterprise_domain = enterprise_account.enterprise_domains.last

      expect(enterprise_domain.domain).to eq('example.com')
      expect(enterprise_domain).not_to be_verified
      expect(enterprise_domain.verification_token).to be_present
      expect(enterprise_domain.verification_filename).to start_with('lumen-domain-verification-')
      expect(response).to redirect_to(client_settings_path)
    end
  end

  describe '#verify' do
    it 'verifies a domain when the verification file is present' do
      enterprise_domain = create(:enterprise_domain, enterprise_account: enterprise_account, verified: false)
      verifier = instance_double(EnterpriseDomainVerification, verified?: true)

      expect(EnterpriseDomainVerification)
        .to receive(:new)
        .with(enterprise_domain)
        .and_return(verifier)

      post :verify, params: { id: enterprise_domain.id }

      expect(enterprise_domain.reload).to be_verified
      expect(enterprise_domain.verified_at).to be_present
      expect(response).to redirect_to(client_settings_path)
    end

    it 'keeps a domain pending when the verification file is missing' do
      enterprise_domain = create(:enterprise_domain, enterprise_account: enterprise_account, verified: false)
      verifier = instance_double(EnterpriseDomainVerification, verified?: false)

      allow(EnterpriseDomainVerification).to receive(:new).and_return(verifier)

      post :verify, params: { id: enterprise_domain.id }

      expect(enterprise_domain.reload).not_to be_verified
      expect(enterprise_domain.verified_at).to be_nil
      expect(response).to redirect_to(client_settings_path)
    end
  end

  describe '#destroy' do
    it 'removes a client domain' do
      enterprise_domain = create(:enterprise_domain, enterprise_account: enterprise_account)

      delete :destroy, params: { id: enterprise_domain.id }

      expect(enterprise_account.enterprise_domains).to be_empty
      expect(response).to redirect_to(client_settings_path)
    end
  end
end
