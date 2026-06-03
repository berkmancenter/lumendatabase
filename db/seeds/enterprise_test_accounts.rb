# Enterprise QA data for testers working through account/domain access flows.

enterprise_test_password = ENV.fetch('ENTERPRISE_TEST_PASSWORD', 'password123')
enterprise_test_notice_count = ENV.fetch('ENTERPRISE_TEST_NOTICE_COUNT', '36').to_i
enterprise_test_source = 'Enterprise test seed'

enterprise_test_accounts = [
  {
    name: 'Acme Streaming',
    email: 'enterprise-acme@lumendatabase.test',
    report_frequency: 'weekly',
    report_recipient_email: 'reports-acme@lumendatabase.test',
    domains: [
      { domain: 'acme-streaming.test', verified: true },
      { domain: 'acme-cdn.test', verified: true },
      { domain: 'pending-acme.test', verified: false }
    ]
  },
  {
    name: 'Nova Games',
    email: 'enterprise-nova@lumendatabase.test',
    report_frequency: 'daily',
    report_recipient_email: 'reports-nova@lumendatabase.test',
    domains: [
      { domain: 'novagames.test', verified: true },
      { domain: 'launcher.novagames.test', verified: true }
    ]
  },
  {
    name: 'Inactive Demo Client',
    email: 'enterprise-inactive@lumendatabase.test',
    active: false,
    report_frequency: 'none',
    domains: [
      { domain: 'inactive-client.test', verified: true }
    ]
  }
]

enterprise_test_recipients = [
  {
    key: :google,
    kind: 'organization',
    name: 'Google',
    address_line_1: '1600 Amphitheatre Parkway',
    city: 'Mountain View',
    state: 'CA',
    zip: '94043',
    country_code: 'US'
  },
  {
    key: :vimeo,
    kind: 'organization',
    name: 'Vimeo',
    address_line_1: '330 W 34th St',
    city: 'New York',
    state: 'NY',
    zip: '10001',
    country_code: 'US'
  },
  {
    key: :searchco,
    kind: 'organization',
    name: 'SearchCo Example',
    address_line_1: '10 Index Plaza',
    city: 'Seattle',
    state: 'WA',
    zip: '98101',
    country_code: 'US'
  }
]

enterprise_test_rights_holders = [
  {
    kind: 'organization',
    name: 'Acme Original Studios',
    address_line_1: '400 Cinema Row',
    city: 'Los Angeles',
    state: 'CA',
    zip: '90028',
    country_code: 'US'
  },
  {
    kind: 'organization',
    name: 'Nova Interactive Rights',
    address_line_1: '77 Pixel Street',
    city: 'Austin',
    state: 'TX',
    zip: '78701',
    country_code: 'US'
  },
  {
    kind: 'organization',
    name: 'Brightline Anti-Piracy',
    address_line_1: '50 Counsel Lane',
    city: 'Boston',
    state: 'MA',
    zip: '02108',
    country_code: 'US'
  }
]

enterprise_test_seed_entity = lambda do |attributes|
  entity = Entity.find_or_initialize_by(
    name: attributes.fetch(:name),
    kind: attributes.fetch(:kind)
  )
  entity.assign_attributes(attributes.except(:key))
  entity.save!
  entity
end

enterprise_test_seed_account = lambda do |attributes|
  account = EnterpriseAccount.find_or_initialize_by(name: attributes.fetch(:name))
  account.assign_attributes(
    active: attributes.fetch(:active, true),
    report_frequency: attributes.fetch(:report_frequency),
    report_recipient_email: attributes[:report_recipient_email],
    notes: 'Seeded enterprise QA account for tester workflows.'
  )
  account.save!

  attributes.fetch(:domains).each do |domain_attributes|
    domain = account.enterprise_domains.find_or_initialize_by(
      domain: domain_attributes.fetch(:domain)
    )
    verified = domain_attributes.fetch(:verified)
    domain.assign_attributes(
      verified: verified,
      verified_at: verified ? (domain.verified_at || Time.current) : nil,
      notes: verified ? 'Verified test domain.' : 'Unverified test domain.'
    )
    domain.save!
  end

  user = User.find_or_initialize_by(email: attributes.fetch(:email))
  user.password = enterprise_test_password
  user.enterprise_account = account
  user.roles = user.roles.to_a | [Role.enterprise]
  user.save!

  account
end

enterprise_test_index_notice = lambda do |notice|
  notice.__elasticsearch__.index_document
rescue StandardError => e
  warn "Skipping Elasticsearch indexing for notice #{notice.id}: #{e.class}: #{e.message}"
end

enterprise_test_seeded_accounts = enterprise_test_accounts.map do |attributes|
  enterprise_test_seed_account.call(attributes)
end

enterprise_test_seeded_recipients = enterprise_test_recipients.each_with_object({}) do |attributes, recipients|
  recipients[attributes.fetch(:key)] = enterprise_test_seed_entity.call(attributes)
end

enterprise_test_seeded_rights_holders = enterprise_test_rights_holders.map do |attributes|
  enterprise_test_seed_entity.call(attributes)
end

enterprise_test_sender = enterprise_test_seed_entity.call(
  kind: 'organization',
  name: 'Lumen Enterprise Test Sender',
  address_line_1: '1 Seed Way',
  city: 'Cambridge',
  state: 'MA',
  zip: '02138',
  country_code: 'US'
)

enterprise_test_notices = enterprise_test_notice_count.times.map do |index|
  notice_number = index + 1
  account = enterprise_test_seeded_accounts[index % 2]
  verified_domains = account.enterprise_domains.verified.order(:domain).pluck(:domain)
  primary_domain = verified_domains[index % verified_domains.length]
  host = notice_number % 4 == 0 ? "media.#{primary_domain}" : primary_domain
  recipient = enterprise_test_seeded_recipients.values[index % enterprise_test_seeded_recipients.length]
  principal = enterprise_test_seeded_rights_holders[index % enterprise_test_seeded_rights_holders.length]
  title = format('Enterprise QA Notice %03d - %s', notice_number, account.name)

  notice = DMCA.find_by(title: title, source: enterprise_test_source)
  next notice if notice.present?

  notice = DMCA.new(
    title: title,
    subject: 'Enterprise QA Takedown Notice',
    source: enterprise_test_source,
    date_sent: notice_number.days.ago,
    date_received: [notice_number - 1, 0].max.days.ago,
    language: 'en',
    body: [
      "Seeded enterprise QA notice for #{account.name}.",
      'Includes matching domains, matching subdomains, unrelated URLs, and copyrighted URLs.'
    ].join(' '),
    tag_list: ['enterprise-qa', account.name.parameterize],
    action_taken: %w[Yes No Partial Unspecified][index % 4],
    works: [
      Work.new(
        description: format('%s catalog asset %03d', account.name, notice_number),
        kind: index.even? ? 'video' : 'game',
        infringing_urls: [
          InfringingUrl.new(url: "https://#{host}/leaks/season-#{notice_number}/episode-1"),
          InfringingUrl.new(url: "https://#{primary_domain}/shared/link-#{notice_number}?source=seed"),
          InfringingUrl.new(url: "https://unrelated.example/reposts/#{account.name.parameterize}-#{notice_number}"),
          InfringingUrl.new(url: "https://mirror.test/downloads/#{notice_number}")
        ],
        copyrighted_urls: [
          CopyrightedUrl.new(url: "https://rights.example/originals/#{account.name.parameterize}/#{notice_number}")
        ]
      )
    ]
  )

  {
    recipient: recipient,
    sender: enterprise_test_sender,
    principal: principal,
    submitter: recipient
  }.each do |role_name, entity|
    notice.entity_notice_roles.build(name: role_name.to_s, entity: entity)
  end

  notice.save!
  notice
end

enterprise_test_notices.compact.each { |notice| enterprise_test_index_notice.call(notice) }

puts
puts 'Enterprise tester seed data is ready.'
puts "Password for seeded enterprise QA users: #{enterprise_test_password}"
puts

enterprise_test_accounts.each do |attributes|
  account = EnterpriseAccount.find_by!(name: attributes.fetch(:name))
  user = User.find_by!(email: attributes.fetch(:email))
  domains = account.enterprise_domains.order(:domain).map do |domain|
    status = domain.verified? ? 'verified' : 'unverified'
    "#{domain.domain} (#{status})"
  end

  puts "#{account.name}#{account.active? ? '' : ' [inactive]'}"
  puts "  login: #{user.email}"
  puts "  domains: #{domains.join(', ')}"
  puts "  reports: #{account.report_frequency}"
end

puts
puts "Seeded/found #{enterprise_test_notices.compact.length} enterprise QA notices."
