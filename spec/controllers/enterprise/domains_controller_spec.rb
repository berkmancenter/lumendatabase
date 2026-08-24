require 'rails_helper'

describe Enterprise::DomainsController do
  let(:enterprise_account) { create(:enterprise_account) }
  let(:user) { create(:user, :enterprise, enterprise_account: enterprise_account) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe '#index' do
    it 'lists domains for the current enterprise account' do
      verified_domain = create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'example.com')
      pending_domain = create(:enterprise_domain, enterprise_account: enterprise_account, domain: 'pending.example', verified: false)
      create(:enterprise_domain)

      get :index

      expect(response).to be_successful
      expect(assigns(:enterprise_account)).to eq(enterprise_account)
      expect(assigns(:enterprise_domains)).to eq([verified_domain, pending_domain])
    end
  end

  describe '#create' do
    it 'adds an unverified domain for the current client' do
      post :create, params: { enterprise_domain: { domain: 'https://Example.com/path' } }

      enterprise_domain = enterprise_account.enterprise_domains.last

      expect(enterprise_domain.domain).to eq('example.com')
      expect(enterprise_domain).not_to be_verified
      expect(enterprise_domain.verification_token).to be_present
      expect(enterprise_domain.verification_filename).to start_with('lumen-domain-verification-')
      expect(response).to redirect_to(enterprise_domains_path)
    end

    it 'auto-verifies and seeds a settings domain when registration dummy data is enabled' do
      generator = Lumen::Enterprise::DummyDataGenerator.new(
        enterprise_account,
        notices_per_domain_range: 1..1,
        random: Random.new(123)
      )
      allow(LumenSetting).to receive(:get).and_call_original
      allow(LumenSetting).to receive(:get)
        .with(Lumen::Enterprise::DummyDataGenerator::SETTING_KEY, cache: false)
        .and_return('1')
      allow(Lumen::Enterprise::DummyDataGenerator).to receive(:new)
        .with(enterprise_account)
        .and_return(generator)

      post :create, params: { enterprise_domain: { domain: 'https://Example.com/path' } }

      enterprise_domain = enterprise_account.enterprise_domains.last

      expect(enterprise_domain).to be_verified
      expect(enterprise_domain.verified_at).to be_present
      expect(DMCA.where(source: Lumen::Enterprise::DummyDataGenerator::SOURCE).count).to eq(1)
      expect(flash[:notice]).to eq('Domain added and auto-verified with dummy data.')
      expect(response).to redirect_to(enterprise_domains_path)
    end
  end

  describe '#verify' do
    it 'verifies a domain when the verification file is present' do
      enterprise_domain = create(:enterprise_domain, enterprise_account: enterprise_account, verified: false)
      verifier = instance_double(Lumen::Enterprise::DomainVerification, verified?: true)

      expect(Lumen::Enterprise::DomainVerification)
        .to receive(:new)
        .with(enterprise_domain)
        .and_return(verifier)

      post :verify, params: { id: enterprise_domain.id }

      expect(enterprise_domain.reload).to be_verified
      expect(enterprise_domain.verified_at).to be_present
      expect(response).to redirect_to(enterprise_domains_path)
    end

    it 'keeps a domain pending when the verification file is missing' do
      enterprise_domain = create(:enterprise_domain, enterprise_account: enterprise_account, verified: false)
      verifier = instance_double(Lumen::Enterprise::DomainVerification, verified?: false)

      allow(Lumen::Enterprise::DomainVerification).to receive(:new).and_return(verifier)

      post :verify, params: { id: enterprise_domain.id }

      expect(enterprise_domain.reload).not_to be_verified
      expect(enterprise_domain.verified_at).to be_nil
      expect(response).to redirect_to(enterprise_domains_path)
    end
  end

  describe '#destroy' do
    it 'removes a client domain' do
      enterprise_domain = create(:enterprise_domain, enterprise_account: enterprise_account)

      delete :destroy, params: { id: enterprise_domain.id }

      expect(enterprise_account.enterprise_domains).to be_empty
      expect(response).to redirect_to(enterprise_domains_path)
    end
  end
end
