Notice.index.delete
Notice.create_elasticsearch_index

Entity.index.delete
Entity.create_elasticsearch_index

# Execute seeds in a logical order
seed_files = %w(
  relevant_questions.rb categories.rb blog_entries.rb risk_triggers.rb
  users.rb
)

seed_files.each { |file| load("db/seeds/#{file}") }

class FakeNotice
  attr_reader :title, :source, :subject, :date_sent, :date_received,
    :body, :body_original, :review_required, :language

  def initialize
    @title = [
      'Lion King', 'Batman', 'Revenge of the Nerds', 'Harry Potter',
      'Star Wars', 'That Movie', 'Some Book', 'This Thing', 'I Give Up'
    ].sample

    @source = ["Online form", "Email", "Phone"].sample
    @subject = "Websearch Infringment Notification via #{@source}"
    @date_sent = (0..100).to_a.sample.days.ago
    @date_received = (0..100).to_a.sample.days.ago

    if rand(100) < 15
      @body = "Some [REDACTED] text"
      @body_original = "Some sensitive text"
      @review_required = true
    else
      @review_required = false
    end

    if rand(100) < 85
      @language = 'en'
    else
      @language = Language.codes.sample
    end
  end

  def categories
    lim = (3..5).to_a.sample

    Category.order('random()').limit(lim)
  end

  def tags
    (1..5).to_a.sample.times.map do
      %w|movie disney youtube sharknado snakes planes|.sample
    end.uniq
  end

  def jurisdictions
    (1..2).to_a.sample.times.map do
      %w|US CA MX GB FI JP|.sample
    end.uniq
  end

  def kind
    %w( movie book video ).sample
  end

  def work_url
    "http://example.com/works/#{title.downcase.gsub(/\s+/, '_')}.ext"
  end

  def work_description
    "#{title} #{kind}".titleize
  end

  def urls
    n = (5..100).to_a.sample

    n.times.map do |i|
      { url: "http://example.com/bad/url_#{i}" }
    end
  end

  def recipient
    [{
      kind: 'organization',
      name: 'Google',
      address_line_1: '1600 Amphitheatre Parkway',
      city: 'Mountain View',
      state: 'CA',
      zip: '94043',
      country_code: 'US'
    },
    {
      kind: 'organization',
      name: 'Twitter, Inc.',
      address_line_1: '100 Maple Leaf Rd.',
      city: 'Quebec',
      state: 'ON',
      zip: 'FFF 222',
      country_code: 'CA'
    }].sample
  end

  def sender
    [{
      name: 'Joe Lawyer',
      kind: 'individual',
      address_line_1: '1234 Anystreet St.',
      city: 'Anytown',
      state: 'CA',
      zip: '94044',
      country_code: 'US'
    },
    {
      name: 'Bill Somebody',
      kind: 'individual',
      address_line_1: '123 Any St.',
      city: 'Town',
      state: 'ON',
      zip: 'FFF 123',
      country_code: 'CA'
    },
    {
      name: 'Steve Simpson',
      kind: 'individual',
      address_line_1: '23 My St.',
      city: 'Scranton',
      state: 'CA',
      zip: '94044',
      country_code: 'US'
    },
    {
      name: 'Mike Itten',
      kind: 'individual',
      address_line_1: '12 Main St.',
      city: 'Springfield',
      state: 'CA',
      zip: '94044',
      country_code: 'US'
    }].sample
  end
end

unless ENV['SKIP_FAKE_DATA']
  count = (ENV['NOTICE_COUNT'] || "500").to_i

  print "\n--> Generating #{count} Fake Notices"

  count.times do
    fake = FakeNotice.new

    Notice.create!(
      title: fake.title,
      subject: fake.subject,
      date_sent: fake.date_sent,
      date_received: fake.date_received,
      source: fake.source,
      category_ids: fake.categories.map(&:id),
      tag_list: fake.tags,
      jurisdiction_list: fake.jurisdictions,
      body: fake.body,
      body_original: fake.body_original,
      review_required: fake.review_required,
      language: fake.language,
      works_attributes: [{
        url: fake.work_url,
        description: fake.work_description,
        kind: fake.kind,
        infringing_urls_attributes: fake.urls
      }],
      entity_notice_roles_attributes: [{
      name: 'recipient', entity_attributes: fake.recipient
    }, {
      name: 'sender', entity_attributes: fake.sender
    }]
    )

    print '.'
  end

  puts
end
