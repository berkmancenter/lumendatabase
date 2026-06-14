require 'rails_helper'

describe Lumen::Enterprise::DomainVerification do
  describe '#verified?' do
    it 'accepts the Lumen verification file over HTTPS' do
      enterprise_domain = build(:enterprise_domain, domain: 'example.com')

      allow(Resolv).to receive(:getaddresses).with('example.com').and_return(['93.184.216.34'])
      stub_request(:get, "https://example.com/#{enterprise_domain.verification_filename}")
        .to_return(status: 200, body: enterprise_domain.verification_file_content)

      expect(described_class.new(enterprise_domain)).to be_verified
    end

    it 'rejects incorrect verification file contents' do
      enterprise_domain = build(:enterprise_domain, domain: 'example.com')

      allow(Resolv).to receive(:getaddresses).with('example.com').and_return(['93.184.216.34'])
      stub_request(:get, "https://example.com/#{enterprise_domain.verification_filename}")
        .to_return(status: 200, body: 'wrong')
      stub_request(:get, "http://example.com/#{enterprise_domain.verification_filename}")
        .to_return(status: 404, body: '')

      expect(described_class.new(enterprise_domain)).not_to be_verified
    end

    it 'does not fetch private network addresses' do
      enterprise_domain = build(:enterprise_domain, domain: 'example.com')

      allow(Resolv).to receive(:getaddresses).with('example.com').and_return(['127.0.0.1'])

      expect(described_class.new(enterprise_domain)).not_to be_verified
    end
  end
end
