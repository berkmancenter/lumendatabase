require 'rails_helper'

describe Lumen::Enterprise::DummyDataGenerator, type: :model do
  subject(:generator) do
    described_class.new(
      account,
      notices_per_domain_range: 2..2,
      random: Random.new(123)
    )
  end

  let(:account) do
    create(
      :enterprise_account,
      name: 'Example Streaming',
      applicant_email: 'rep@example.com',
      interested_domains: [
        'Example.com',
        'https://video.example.org/watch/123',
        'not-a-domain'
      ].join("\n")
    )
  end

  describe '#run' do
    it 'creates verified enterprise domains from interested domains' do
      generator.run

      domains = account.enterprise_domains.order(:domain)

      expect(domains.map(&:domain)).to eq(%w[example.com video.example.org])
      expect(domains).to all(be_verified)
      expect(domains.map(&:verified_at)).to all(be_present)
    end

    it 'marks existing interested domains verified' do
      existing_domain = create(
        :enterprise_domain,
        enterprise_account: account,
        domain: 'example.com',
        verified: false,
        verified_at: nil
      )

      generator.run

      expect(existing_domain.reload).to be_verified
      expect(existing_domain.verified_at).to be_present
    end

    it 'creates dummy data for explicitly supplied settings domains' do
      settings_domain = create(
        :enterprise_domain,
        enterprise_account: account,
        domain: 'Settings.Example',
        verified: false,
        verified_at: nil
      )

      created_notices = generator.run(domains: [settings_domain.domain])

      expect(settings_domain.reload).to be_verified
      expect(settings_domain.verified_at).to be_present
      expect(created_notices.count).to eq(2)
      expect(generated_notices_for('settings.example').count).to eq(2)
      expect(account.enterprise_domains.where(domain: 'example.com')).not_to exist
    end

    it 'creates dummy notices with enterprise-visible matching URLs' do
      created_notices = generator.run

      expect(created_notices.count).to eq(4)
      expect(DMCA.where(source: described_class::SOURCE).count).to eq(4)

      notice = generated_notices_for('example.com').first
      urls = notice.works.flat_map(&:infringing_urls).map(&:url)

      expect(urls).to include(
        a_string_matching(%r{\Ahttps://example\.com/}),
        a_string_matching(%r{\Ahttps://media\.example\.com/})
      )
      expect(Lumen::Enterprise::NoticeAccess.for_account(account, notice)).to be_allowed
    end

    it 'creates missing notices in randomized order across domains' do
      created_notices = generator.run

      created_domains = created_notices.map do |notice|
        notice.notes[/domain=(.+)\z/, 1]
      end

      expect(created_domains).to eq([
        'video.example.org',
        'example.com',
        'example.com',
        'video.example.org'
      ])
    end

    it 'does not duplicate notices when run again' do
      generator.run

      expect { generator.run }
        .not_to change { DMCA.where(source: described_class::SOURCE).count }
    end
  end

  def generated_notices_for(domain)
    DMCA.where(
      source: described_class::SOURCE,
      notes: "Generated dummy data for enterprise_account_id=#{account.id} domain=#{domain}"
    )
  end
end
