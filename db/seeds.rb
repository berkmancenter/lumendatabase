################################################################################
# Blog Entries
################################################################################
BlogEntry.create!(
  author: 'Adam Holland',
  title: 'Possibly The First Serious 512(f) Ruling in D. Mass',
  abstract: 'A Massachusetts court is hearing a case triggered by a DMCA takedown notice in which the sender admitted that they new the recipient had a fair use claim.',
  published_at: Time.local(2013, 5, 13),
  content: %{
Chilling Effects fans and those who follow takedown notice stories will
recall the relatively recent brouhaha in which a NASCAR fan filmed a
crash with his cellphone and posted it to YouTube, whereupon NASCAR
asserted claim in the cellphone video and filed a DMCA takedown notice
to get the video removed.  you can see the fan video in question
[here][vid1], and a more revealing video of the accident, probably
from the venue cameras, [here][vid2].

[vid1]: https://www.youtube.com/watch?feature=player_detailpage&v=wVW65Tyji_s
[vid2]: https://www.youtube.com/watch?v=cDgg_hTWE4c

Google pushed back and left the video up, and in short order NASCAR was
backing down from its claims of copyright infringement, going to far as
to say that the issue for them had in fact never been about copyright.

This prompted much criticism of what seemed like a knowing and blatant
abuse of the DMCA process. Media guru Dan Gilmor, criticizing NASCAR's
behavior, [suggested][] (correctly, as it turns out) that nothing at all
would come of it.  We here wondered, if this open admission that a DMCA
notice had been sent when the sender knew, and later acknowledged, that
it had nothing to do with copyright couldn't trigger 512(f), if there
could be any [512(f)][512-f] situation so egregious that the notice sender would
suffer the (admittedly weak) associated penalties.

[suggested]: https://twitter.com/dangillmor/status/306537081142931456
[512-f]:     http://www.copyright.gov/title17/92chap5.html#512

Well, it's looking as though just such a situation has arisen in
Massachusetts, where a Boston OB/GYN, Dr. Amy Tuteur, has been in a
rather acrimonious back-and-forth with an Illinois doula, Gina
Crosley-Corcoran. ["C-C"]

TechDirt has [and our colleagues at the Digital Media Law
Project][legal-fight], together with the EFF, have not only [taken an
interest][interest], but have sought to file an amicus brief.
Intriguingly, the defendants are opposing the brief on the grounds that
their opponent's lawyers are too good. Go, DMLP!

[legal-fight]: https://www.techdirt.com/articles/20130509/01272923016/key-legal-fight-shaping-up-over-legality-dmca-abuses.shtml
[interest]:    http://www.dmlp.org/threats/tuteur-v-crosley-corcoran

You can dive into all the details at your leisure, but we here at
Chilling Effects are keenly interested in this case because of what it
portends for the DMCA notice and takedown process.  Here's the DMLP on
the key elements from our perspective. [emphasis added]

> The dispute lead to Crosley-Corcoran posting a photograph of herself
> on her blog extending her middle finger, with the accompanying
> comment, "I don't want to leave you without something you can take
> back to your blog and obsess over, so here's a picture of me, sitting
> at my dining room table[.]" Tuteur responded on her blog by posting
> the photo, arguing that it was an "outstanding example of table
> pounding" and accusing Crosley-Corcoran of being afraid to answer
> questions posed by Tuteur.
>
> At this point, Crosley-Corcoran began threatening Tuteur with a
> copyright infringement lawsuit, and sent two DMCA takedown notices to
> the services hosting Tuteur's blog. According to the complaint, the
> second notice was sent after an alleged conversation between parties
> wherein Crosley-Corcoran's attorney **acknowledged that she did not
> have a valid copyright claim.** [because the reposting was a fair
> use]

So, this seems like an ironclad 512(f) claim, in that this is a clear
abuse of the DMCA process, in that C-C sent the notice knowing that
Tuteur's use of the photo was not an infringing one.

Recall that a fair use is not a defense to an infringement, but in fact
not an infringement at all. "[the fair use...is not an
infringement....][quote]"

[quote]: http://www.copyright.gov/title17/92chap1.html#107

However, the court, sua sponte, raised the idea that a notice sender
*might not have to consider* a recipient's fair uses when sending a
notice. [Arguably, no one does this anyway, but the idea of a precedent
being set such that there's no need to do so is disturbing.]

It's so easy to remove content that the possibility of notice
recipients' uses being fair ones being reason to leave content up is an
already thin reed. Fair use is already complex, and many users don't
attempt to rely on it because its determination, ultimately by a court,
if challenged, is too expensive. Narrowing its use and scope is not the
direction in which we want to go.

As the DMLP points out:

> the notice requirements of the DMCA do not require a copyright owner
> to merely claim use without permission; they require a copyright owner
> to state that the use "is not authorized by the copyright owner, its
> agent, or the law." [emphasis added] (17 U.S.C.  § 512(c)(3)(A)(v).)
> Similarly, Section 512(f) allows recovery against anyone who knowingly
> misrepresents "that material or activity is infringing," and as the
> Copyright Act and courts repeatedly note, "a fair use is not an
> infringement of copyright.

If the court ends up where it appears to be looking, 512(f) will be rendered meaningless, and there will be nothing at all holding back willful misuse of the DMCA's takedown process.

Keep an eye on this case!
  }
)

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
# Notices
################################################################################
Notice.create!(
  title: "Lion King on YouTube",
  subject: "Infringement Notification via Blogger Complaint",
  date_received: Time.now,
  source: "Online Form",
  category_ids: [dmca, bookmarks, chilling].map(&:id),
  tag_list: 'movies, disney, youtube',
  works_attributes: [ {
    url: "http://disney.com/lion_king.mp4",
    description: "Lion King Video",
    kind: 'movie',
    infringing_urls_attributes: [
      { url: 'http://example.com/bad_url_1'} ,
      { url: 'http://example.com/bad_url_2'} ,
      { url: 'http://example.com/bad_url_3'} ,
      { url: 'http://example.com/bad_url_4'} ,
      { url: 'http://example.com/bad_url_5'}
    ],
  }],
  entity_notice_roles_attributes: [ {
    name: 'recipient',
    entity_attributes: {
      kind: 'organization',
      name: 'Google',
      address_line_1: '1600 Amphitheatre Parkway',
      city: 'Mountain View',
      state: 'CA',
      zip: '94043',
      country_code: 'US'
    }
  }, {
    name: 'submitter',
    entity_attributes: {
      name: 'Joe Lawyer',
      kind: 'individual',
      address_line_1: '1234 Anystreet St.',
      city: 'Anytown',
      state: 'CA',
      zip: '94044',
      country_code: 'US'
    }
  }]
)
