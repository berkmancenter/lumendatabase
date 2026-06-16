require 'rails_helper'

describe Enterprise::ReportsMailer, type: :mailer do
  describe '#report_digest' do
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
        .report_digest(enterprise_account, starts_at, ends_at)
        .deliver_now
    end

    before do
      allow(Notice.__elasticsearch__.client).to receive(:search).and_return(
        'hits' => {
          'hits' => [
            {
              '_source' => { 'id' => notice.id },
              '_id' => notice.id.to_s,
              'sort' => [notice.created_at.iso8601, notice.id.to_s]
            }
          ]
        }
      )
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

  describe '#on_demand_report_ready' do
    let(:enterprise_report) do
      create(
        :enterprise_report,
        requested_by_email: 'client@example.com',
        starts_at: Time.zone.local(2026, 6, 1),
        ends_at: Time.zone.local(2026, 6, 15).end_of_day
      )
    end
    let(:mail) do
      described_class
        .on_demand_report_ready(enterprise_report)
        .deliver_now
    end

    it 'sends the ready notification to the requester' do
      expect(mail.subject).to eq('Your Lumen Enterprise report is ready')
      expect(mail.to).to eq(['client@example.com'])
      expect(mail.attachments).to be_empty
    end

    it 'links to the tokenized download URL' do
      expect(mail.body.encoded).to include(
        enterprise_report_url(
          token: enterprise_report.download_token,
          host: Chill::Application.config.site_host
        )
      )
    end
  end
end
