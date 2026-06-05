enterprise_role = Role.enterprise

enterprise_account = EnterpriseAccount.find_or_initialize_by(
  name: 'Example Business'
)
enterprise_account.assign_attributes(
  plan: 'pro',
  payment_method: 'credit_card',
  paid_until: 1.month.from_now,
  report_frequency: 'weekly',
  report_recipient_email: 'enterprise@lumendatabase.org',
  notes: 'Seeded enterprise account for domain-scoped notice access.'
)
enterprise_account.save!

%w[
  business.example
  enterprise-demo.test
].each do |domain|
  enterprise_domain = enterprise_account.enterprise_domains.find_or_initialize_by(
    domain: domain
  )
  enterprise_domain.assign_attributes(
    verified: true,
    verified_at: enterprise_domain.verified_at || Time.current,
    notes: 'Seeded verified enterprise domain.'
  )
  enterprise_domain.save!
end

enterprise_user = User.find_or_initialize_by(
  email: 'enterprise@lumendatabase.org'
)
enterprise_user.password = 'password' if enterprise_user.new_record? ||
                                         enterprise_user.encrypted_password.blank?
enterprise_user.enterprise_account = enterprise_account
enterprise_user.roles = enterprise_user.roles.to_a | [enterprise_role]
enterprise_user.save!

seed_entity = lambda do |attributes|
  entity = Entity.find_or_initialize_by(
    name: attributes[:name],
    kind: attributes[:kind]
  )
  entity.assign_attributes(attributes)
  entity.save!
  entity
end

google = seed_entity.call(
  kind: 'organization',
  name: 'Google',
  address_line_1: '1600 Amphitheatre Parkway',
  city: 'Mountain View',
  state: 'CA',
  zip: '94043',
  country_code: 'US'
)

vimeo = seed_entity.call(
  kind: 'organization',
  name: 'Vimeo',
  address_line_1: '330 W 34th St',
  city: 'New York',
  state: 'NY',
  zip: '10001',
  country_code: 'US'
)

sender = seed_entity.call(
  kind: 'organization',
  name: 'Example Rights Management',
  address_line_1: '101 Rights Way',
  city: 'Boston',
  state: 'MA',
  zip: '02108',
  country_code: 'US'
)

principal = seed_entity.call(
  kind: 'organization',
  name: 'Example Studios',
  address_line_1: '500 Studio Ave',
  city: 'Los Angeles',
  state: 'CA',
  zip: '90028',
  country_code: 'US'
)

create_enterprise_notice = lambda do |attributes|
  title = attributes.fetch(:title)
  source = 'Enterprise seed'
  notice = DMCA.find_by(title: title, source: source)

  if notice.blank?
    notice = DMCA.new(
      title: title,
      subject: attributes.fetch(:subject),
      source: source,
      date_sent: attributes.fetch(:date_received) - 1.day,
      date_received: attributes.fetch(:date_received),
      language: 'en',
      body: attributes.fetch(:body),
      works: [
        Work.new(
          description: attributes.fetch(:work_description),
          kind: 'webpage',
          infringing_urls: attributes.fetch(:infringing_urls).map do |url|
            InfringingUrl.new(url: url)
          end,
          copyrighted_urls: attributes.fetch(:copyrighted_urls).map do |url|
            CopyrightedUrl.new(url: url)
          end
        )
      ]
    )

    {
      recipient: attributes.fetch(:recipient),
      sender: sender,
      principal: principal,
      submitter: attributes.fetch(:recipient)
    }.each do |role_name, entity|
      notice.entity_notice_roles.build(name: role_name.to_s, entity: entity)
    end

    notice.save!
  end

  notice
end

enterprise_notice_count = 200
enterprise_notice_titles = [
  'DMCA (Copyright) Complaint to Google - Business Example',
  'DMCA (Copyright) Complaint to Vimeo - Enterprise Demo'
]

enterprise_notices = enterprise_notice_count.times.map do |index|
  notice_number = index + 1
  enterprise_domain = notice_number.odd? ? 'business.example' : 'enterprise-demo.test'
  recipient = notice_number.odd? ? google : vimeo
  host = notice_number % 5 == 0 ? "cdn.#{enterprise_domain}" : enterprise_domain
  title = enterprise_notice_titles[index] ||
          format('DMCA (Copyright) Enterprise Seed Notice %03d', notice_number)

  create_enterprise_notice.call(
    title: title,
    subject: 'Enterprise Seed Takedown Notice',
    recipient: recipient,
    date_received: (notice_number % 45).days.ago,
    work_description: format('Seeded enterprise work %03d', notice_number),
    body: 'Seeded notice containing a mix of enterprise and unrelated URLs.',
    infringing_urls: [
      "https://#{host}/seeded-work-#{notice_number}/primary",
      "https://#{enterprise_domain}/seeded-work-#{notice_number}/secondary",
      "https://unrelated.example/mirror/seeded-work-#{notice_number}",
      "https://another-site.example/reposts/seeded-work-#{notice_number}",
      "https://vimeo.com/enterprise-seed-#{notice_number}"
    ],
    copyrighted_urls: [
      "https://example-studios.test/originals/seeded-work-#{notice_number}"
    ]
  )
end

enterprise_notices.each { |notice| notice.__elasticsearch__.index_document }
