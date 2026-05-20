require 'rails_helper'

describe EnterpriseReportsMailer, type: :mailer do
  describe '#enterprise_report_digest' do
    let(:enterprise_account) do
      create(
        :enterprise_account,
        name: 'Example Business',
        report_recipient_email: 'reports@example.com'
      )
    end
    let(:starts_at) { 1.day.ago }
    let(:ends_at) { Time.current }
    let!(:enterprise_domain) do
      create(
        :enterprise_domain,
        enterprise_account: enterprise_account,
        domain: 'business.example',
        verified: true
      )
    end
    let!(:notice) do
      create(
        :dmca,
        title: 'Business domain notice',
        works: [
          Work.new(
            infringing_urls: [
              InfringingUrl.new(url: 'https://business.example/path')
            ],
            copyrighted_urls: []
          )
        ]
      )
    end
    let(:mail) do
      described_class
        .enterprise_report_digest(enterprise_account, starts_at, ends_at)
        .deliver_now
    end

    it 'sets the subject and recipient' do
      expect(mail.subject).to eq('Lumen notice report for Example Business')
      expect(mail.to).to eq(['reports@example.com'])
    end

    it 'includes matching notice URLs in the body' do
      expect(mail.body.encoded).to include('https://business.example/path')
    end

    it 'attaches a structured JSON report' do
      attachment = mail.attachments.first
      json = JSON.parse(attachment.body.decoded)

      expect(attachment.mime_type).to eq('application/json')
      expect(json['notices'].first['id']).to eq(notice.id)
      expect(json['notices'].first['matching_infringing_urls']).to eq(
        ['https://business.example/path']
      )
    end
  end
end
