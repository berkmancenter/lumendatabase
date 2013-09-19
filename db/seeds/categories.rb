Category.create!(name: 'Chilling Effects')
Category.create!(name: 'Copyright').tap do |p|
  Category.create!(
    parent: p,
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
    }
  )
  Category.create!(parent: p, name: 'Copyright and Fair Use')
  Category.create!(parent: p, name: 'Derivative Works')

  Category.create!(parent: p, name: 'DMCA Safe Harbor').tap do |pp|
    Category.create!(parent: pp, name: 'DMCA Notices')
  end

  Category.create!(parent: p, name: 'DMCA Subpoenas')
  Category.create!(parent: p, name: 'Piracy or Copyright Infringement')
  Category.create!(parent: p, name: 'Reverse Engineering')
end

Category.create!(name: 'Defamation')
Category.create!(name: 'Fan Fiction')

Category.create!(name: 'International').tap do |p|
  Category.create!(parent: p, name: 'Court Orders')
end

Category.create!(name: 'John Doe Anonymity')
Category.create!(name: 'Linking')
Category.create!(name: 'No Action')

Category.create!(name: 'Patent').tap do |p|
  Category.create!(parent: p, name: 'E-Commerce Patents')
end

Category.create!(name: 'Responses')
Category.create!(name: 'Right of Publicity')
Category.create!(name: 'Trade Secret')

Category.create!(name: 'Trademark').tap do |p|
  Category.create!(parent: p, name: 'Domain Names and Trademarks').tap do |pp|
    Category.create!(parent: pp, name: 'ACPA')
    Category.create!(parent: pp, name: 'Documenting Your Domain Defense')
    Category.create!(parent: pp, name: 'UDRP')
  end

  Category.create!(parent: p, name: 'Protest, Parody and Criticism Sites')
end

Category.create!(name: 'Uncategorized')
