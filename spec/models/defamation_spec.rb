require 'spec_helper'

RSpec.describe Defamation, type: :model do
  it 'has the expected entity notice roles' do
    expected = %w[recipient sender submitter]
    expect(described_class::DEFAULT_ENTITY_NOTICE_ROLES).to match_array expected
  end

  it 'has the expected partial path' do
    notice = build(:defamation)
    expect(notice.to_partial_path).to eq 'notices/notice'
  end

  it 'has the right model name' do
    expect(described_class.model_name).to eq 'Notice'
  end

  it 'hides identities when the recipient is google or youtube' do
    recipient_names = ['Google', 'Google, Inc.', 'Google LLC', 'YouTube LLC']
    notice = create(:defamation, :with_facet_data)

    recipient_names.each do |recipient_name|
      notice.recipient.name = recipient_name
      notice.auto_redact
      notice.recipient.save

      expect(notice.sender.name).to eq Lumen::REDACTION_MASK
    end
  end

  describe 'TLD-only URL redaction' do
    let(:notice) { create(:defamation) }
    let(:entity) { create(:entity, name: entity_name) }
    let(:work) do
      Work.new(
        description: 'Test',
        infringing_urls: [],
        copyrighted_urls: []
      )
    end

    before do
      notice.works << work
      create(:entity_notice_role, notice: notice, entity: entity, name: 'submitter')
      notice.reload
    end

    subject do
      notice.auto_redact
      notice.save!
    end

    context 'when notice is from Google' do
      let(:entity_name) { 'Google LLC' }

      it 'redacts TLD-only URLs and saves original' do
        url = build(:infringing_url, url: 'http://example.com')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://e[redacted]e.com')
        expect(url.url_original).to eq('http://example.com')
      end

      it 'does not redact URLs with a path' do
        url = build(:infringing_url, url: 'http://example.com/page')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://example.com/page')
        expect(url.url_original).to eq('http://example.com/page')
      end

      it 'does not redact URLs with a query string' do
        url = build(:infringing_url, url: 'http://example.com?ref=abc')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://example.com?ref=abc')
        expect(url.url_original).to eq('http://example.com?ref=abc')
      end

      it 'does not crash on malformed URLs' do
        url = build(:infringing_url, url: 'ht!tp:/broken')
        work.infringing_urls << url

        expect { subject }.not_to raise_error
        expect(url.url).to eq('ht!tp:/broken')
      end

      it 'handles subdomains correctly' do
        url = build(:infringing_url, url: 'http://www.example.com')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://www.e[redacted]e.com')
      end

      it 'redacts URLs with https scheme' do
        url = build(:infringing_url, url: 'https://vapeextravaganza.toy')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('https://v[redacted]a.toy')
      end

      it 'redacts single-letter domains' do
        url = build(:infringing_url, url: 'http://x.io')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://x[redacted].io')
      end

      it 'redacts URLs with trailing slashes' do
        url = build(:infringing_url, url: 'http://example.com/')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://e[redacted]e.com')
        expect(url.url_original).to eq('http://example.com/')
      end
    end

    context 'when notice is NOT from Google' do
      let(:entity_name) { 'Other Company' }

      it 'does not redact anything' do
        url = build(:infringing_url, url: 'http://example.com')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://example.com')
        expect(url.url_original).to eq('http://example.com')
      end
    end

    context 'when second level is used' do
      let(:entity_name) { 'Google LLC' }

      it 'redacts TLD-only URLs with second level domains' do
        url = build(:infringing_url, url: 'http://example.co.uk')
        work.infringing_urls << url

        subject

        expect(url.url).to eq('http://e[redacted]e.co.uk')
        expect(url.url_original).to eq('http://example.co.uk')
      end
    end
  end
end
