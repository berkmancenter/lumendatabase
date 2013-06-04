################################################################################
# Relevant Questions
################################################################################
questions = []
questions << RelevantQuestion.new(
  question: "What is the Anti-Cybersquatting Consumer Protection Act (ACPA)?",
  answer: %{
The ACPA (codified as [15 USC 1125(d)][1125] is aimed at people who register a
domain name with the intention of taking financial advantage of another's
trademark. For instance, if BURGER KING did not have a web site, and you
registered www.BURGERKING.com with the intent of selling the site to BURGER
KING for a royal ransom, you could be liable under ACPA.

[1125]: http://www4.law.cornell.edu/uscode/15/1125.html#d

ACPA applies to people who:

1. have a bad faith intent to profit from a domain name; and
2. register, use or traffic in a domain name;
3. that is identical, confusingly similar, or dilutive of certain trademarks.
   The trademark does not have to be registered.

ACPA provides that cyberpirates can be fined between $1,000 and $100,000 per
domain name for which they are found liable, as well as being forced to
transfer the domain name.

Somewhat more broadly, the Act is meant to reduce consumers' confusion about
the source and sponsorship of Internet web pages. The idea is to provide
customers with a measure of reliability, so that when they visit
www.burgerking.com, they will be able to find actual Burger King products, not
something entirely different. It also protects mark owners from loss of
customer goodwill that might occur if others used the trademark to market
disreputable goods or services.

See the module on [ACPA][] to find out more about bad faith and legitimate
defenses.

[acpa]: http://www.chillingeffects.org/acpa/
  }
)

questions << RelevantQuestion.new(
  question: "Who can use the ACPA?",
  answer: %{
The owner of any trademark protected under US federal law, whether registered
or not, so long as the mark:

* is distinctive at the time of registration of the domain name, or
* is a famous mark at the time of registration, or
* is a "mark, word or name" that is protected because it is reserved for use by
  the Red Cross or the U.S. Olympic Committee.
  }
)

################################################################################
# Categories, Category Managers
################################################################################
dmca = Category.create!(
  name: 'Anticircumvention (DMCA)',
  description: %{
In the online world, the potentially infringing activities of
individuals are stored and transmitted through the networks of third
parties. Web site hosting services, Internet service providers, and
search engines that link to materials on the Web are just some of the
service providers that transmit materials created by others.  Section
512 of the Digital Millennium Copyright Act (DMCA) protects online
service providers (OSPs) from liability for information posted or
transmitted by subscribers if they quickly remove or disable access to
material identified in a copyright holder's complaint.

While the safe harbor provisions provide a way for individuals to
object to the removal of their materials once taken down, they do not
require service providers to notify those individuals before their
allegedly infringing materials are removed. If the material on your
site does not infringe the intellectual property rights of a copyright
owner and it has been improperly removed from the Web, you can file a
counter-notice with the service provider, who must transmit it to the
person who made the complaint. If the copyright owner does not notify
the service provider within 14 business days that it has filed a claim
against you in court, your materials can be restored to the Internet.
  },
  relevant_questions: questions
)

bookmarks = Category.create!(name: 'Bookmarks')
chilling  = Category.create!(name: 'Chilling Effects')

category_names = [
  'Copyright',
  'Copyright and Fair Use',
  'Court Orders',
  'Defamation',
  'Derivative Works',
  'DMCA Notices',
  'DMCA Safe Harbor',
  'DMCA Subpoenas',
  'Documenting Your Domain Defense',
  'Domain Names and Trademarks',
  'E-Commerce Patents',
  'Fan Fiction',
  'International',
  'John Doe Anonymity',
  'Linking',
  'No Action',
  'Patent',
  'Piracy or Copyright Infringement',
  'Protest, Parody and Criticism Sites',
  'References',
  'Responses',
  'Reverse Engineering',
  'Right of Publicity',
  'Trade Secret',
  'Trademark',
  'UDRP',
  'Uncategorized'
]

category_names.each do |category_name|
  Category.create!(name: category_name)
end

CategoryManager.create!(
  name: "Harvard Law",
  categories: [dmca, bookmarks, chilling]
)

################################################################################
# Submissions
################################################################################
Submission.new(
  title: "Lion King on YouTube",
  date_received: Time.now,
  source: "Online Form",
  category_ids: [dmca, bookmarks, chilling].map(&:id),
  tag_list: 'movies, disney, youtube',
  works: [ {
    url: "http://disney.com/lion_king.mp4",
    description: "Lion King Video",
    infringing_urls: [
      'http://example.com/bad_url_1',
      'http://example.com/bad_url_2',
      'http://example.com/bad_url_3',
      'http://example.com/bad_url_4',
      'http://example.com/bad_url_5',
    ],
  }],
  entities: [
    { name: 'Google',
      kind: 'organization',
      role: 'recipient',
      address_line_1: '1600 Amphitheatre Parkway',
      city: 'Mountain View',
      state: 'CA',
      zip: '94043',
      country_code: 'US' },

    { name: 'Joe Lawyer',
      kind: 'individual',
      role: 'submitter',
      address_line_1: '1234 Anystreet St.',
      city: 'Anytown',
      state: 'CA',
      zip: '94044',
      country_code: 'US' }
  ]
).save
