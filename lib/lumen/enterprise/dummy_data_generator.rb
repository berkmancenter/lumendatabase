# frozen_string_literal: true

require 'digest'
require 'faker'

class Lumen::Enterprise::DummyDataGenerator
  SETTING_KEY = 'enterprise_registration_dummy_data_enabled'.freeze
  SOURCE = 'Enterprise registration dummy data'.freeze
  NOTICE_COUNT_RANGE = 100..200
  GENERATOR_TAG = 'enterprise-registration-dummy-data'.freeze
  ACTIONS = %w[Yes No Partial Unspecified].freeze
  WORK_KINDS = %w[
    article
    book
    game
    image
    movie
    music
    software
    video
    webpage
  ].freeze
  RECIPIENT_NAMES = [
    'Google',
    'Vimeo',
    'Cloudflare',
    'Microsoft Bing',
    'SearchCo Example'
  ].freeze

  def self.enabled?
    LumenSetting.get(SETTING_KEY, cache: false) == '1'
  end

  def initialize(
    enterprise_account,
    notices_per_domain_range: NOTICE_COUNT_RANGE,
    random: Random.new
  )
    @enterprise_account = enterprise_account
    @notices_per_domain_range = notices_per_domain_range
    @random = random
  end

  def run(domains: nil)
    domain_values = domains || enterprise_account.interested_domains

    missing_notice_jobs(domain_values).shuffle(random: random).map do |domain, notice_number|
      create_notice(domain, notice_number)
    end
  end

  private

  attr_reader :enterprise_account, :notices_per_domain_range, :random

  def normalized_domains(domain_values)
    Array(domain_values)
      .flat_map { |value| value.to_s.split(/[\s,;]+/) }
      .map { |value| EnterpriseDomain.normalize(value) }
      .select { |domain| domain.match?(EnterpriseDomain::DOMAIN_FORMAT) }
      .uniq
  end

  def verify_domain(domain)
    enterprise_domain = enterprise_account.enterprise_domains.find_or_initialize_by(
      domain: domain
    )

    enterprise_domain.assign_attributes(
      verified: true,
      verified_at: enterprise_domain.verified_at || Time.current
    )
    enterprise_domain.notes = domain_note if enterprise_domain.notes.blank?
    enterprise_domain.save!

    enterprise_domain
  end

  def missing_notice_jobs(domain_values)
    normalized_domains(domain_values).flat_map do |domain|
      enterprise_domain = verify_domain(domain)

      missing_notice_numbers_for_domain(enterprise_domain.domain).map do |notice_number|
        [enterprise_domain.domain, notice_number]
      end
    end
  end

  def missing_notice_numbers_for_domain(domain)
    existing_count = generated_notice_scope(domain).count
    target_count = target_notice_count(domain)
    return [] if existing_count >= target_count

    (existing_count + 1)..target_count
  end

  def generated_notice_scope(domain)
    DMCA.where(source: SOURCE, notes: notice_note(domain))
  end

  def target_notice_count(domain)
    minimum, maximum = notices_per_domain_range.minmax
    minimum + stable_number_for(domain, maximum - minimum)
  end

  def stable_number_for(domain, maximum_offset)
    Digest::SHA256.hexdigest("#{enterprise_account.id}:#{domain}").hex %
      (maximum_offset + 1)
  end

  def create_notice(domain, notice_number)
    notice = DMCA.new(
      title: notice_title(domain, notice_number),
      subject: 'DMCA takedown request',
      source: SOURCE,
      date_sent: date_received(notice_number) - random.rand(1..3).days,
      date_received: date_received(notice_number),
      language: 'en',
      body: notice_body(domain),
      notes: notice_note(domain),
      tag_list: notice_tags(domain),
      action_taken: sample(ACTIONS),
      works: [work(domain, notice_number)]
    )

    notice.entity_notice_roles.build(name: 'recipient', entity: sample(recipients))
    notice.entity_notice_roles.build(name: 'sender', entity: sender)
    notice.entity_notice_roles.build(name: 'principal', entity: sample(principals))
    notice.entity_notice_roles.build(name: 'submitter', entity: sender)

    notice.save!
    notice
  end

  def date_received(notice_number)
    notice_number.days.ago - random.rand(0..18).hours
  end

  def notice_title(domain, notice_number)
    [
      "Enterprise registration dummy notice #{enterprise_account.id}",
      domain,
      format('%03d', notice_number),
      Faker::Book.title
    ].join(' - ')
  end

  def notice_body(domain)
    [
      "#{sender.name} submitted this sample notice for #{enterprise_account.name}.",
      "The allegedly infringing material includes URLs on #{domain} and related subdomains.",
      Faker::Lorem.paragraph(sentence_count: 4),
      Faker::Lorem.paragraph(sentence_count: 3)
    ].join("\n\n")
  end

  def notice_note(domain)
    "Generated dummy data for enterprise_account_id=#{enterprise_account.id} domain=#{domain}"
  end

  def domain_note
    'Auto-verified from Enterprise registration interested domains for dummy data.'
  end

  def notice_tags(domain)
    [
      GENERATOR_TAG,
      "enterprise-account-#{enterprise_account.id}",
      domain.parameterize
    ]
  end

  def work(domain, notice_number)
    Work.new(
      description: work_description(domain, notice_number),
      kind: sample(WORK_KINDS),
      infringing_urls: infringing_urls(domain, notice_number),
      copyrighted_urls: copyrighted_urls(notice_number)
    )
  end

  def work_description(domain, notice_number)
    [
      Faker::Commerce.product_name,
      Faker::Book.title,
      domain,
      format('#%03d', notice_number)
    ].join(' - ')
  end

  def infringing_urls(domain, notice_number)
    [
      InfringingUrl.new(url: "https://#{domain}/#{slug}/#{notice_number}"),
      InfringingUrl.new(url: "https://media.#{domain}/watch/#{slug}"),
      InfringingUrl.new(url: "https://cdn.#{domain}/downloads/#{slug}?ref=#{notice_number}"),
      InfringingUrl.new(url: "https://#{Faker::Internet.domain_name}/mirror/#{slug}"),
      InfringingUrl.new(url: "https://#{Faker::Internet.domain_name}/repost/#{slug}")
    ]
  end

  def copyrighted_urls(notice_number)
    [
      CopyrightedUrl.new(
        url: "https://rights.example/originals/#{enterprise_account.id}/#{notice_number}/#{slug}"
      )
    ]
  end

  def recipients
    @recipients ||= RECIPIENT_NAMES.each_with_index.map do |name, index|
      entity(
        name: "#{name} Enterprise Demo Recipient #{enterprise_account.id}-#{index + 1}",
        email: "#{name.parameterize}-demo-#{enterprise_account.id}@example.com"
      )
    end
  end

  def sender
    @sender ||= entity(
      name: "#{enterprise_account.name} Enterprise Demo Brand Protection #{enterprise_account.id}",
      email: enterprise_account.applicant_email.presence || Faker::Internet.email
    )
  end

  def principals
    @principals ||= 5.times.map do |index|
      entity(
        name: "#{Faker::Company.name} Enterprise Demo Rights Holder #{enterprise_account.id}-#{index + 1}",
        email: Faker::Internet.email
      )
    end
  end

  def entity(name:, email:)
    entity = Entity.find_or_initialize_by(name: name, kind: 'organization')
    return entity if entity.persisted?

    entity.assign_attributes(
      address_line_1: Faker::Address.street_address[0, 255],
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip: Faker::Address.zip_code,
      country_code: 'US',
      phone: Faker::PhoneNumber.phone_number,
      email: email,
      url: Faker::Internet.url
    )
    entity.save!
    entity
  end

  def sample(values)
    values[random.rand(values.length)]
  end

  def slug
    Faker::Lorem.words(number: random.rand(2..5)).join('-').parameterize.presence ||
      SecureRandom.hex(4)
  end
end
