def topics
  lim = (3..5).to_a.sample

  Topic.order('random()').limit(lim)
end

BlogEntry.create!(
  author: 'Adam Holland',
  title: 'Possibly The First Serious 512(f) Ruling in D. Mass',
  abstract: 'A Massachusetts court is hearing a case triggered by a DMCA takedown notice in which the sender admitted that they new the recipient had a fair use claim.',
  published_at: Time.zone.local(2013, 5, 13),
  topics: topics,
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
> agent, or the law." \\[emphasis added] (17 U.S.C.  § 512(c)(3)(A)(v).)
> Similarly, Section 512(f) allows recovery against anyone who knowingly
> misrepresents "that material or activity is infringing," and as the
> Copyright Act and courts repeatedly note, "a fair use is not an
> infringement of copyright.

If the court ends up where it appears to be looking, 512(f) will be
rendered meaningless, and there will be nothing at all holding back
willful misuse of the DMCA's takedown process.

Keep an eye on this case!
  }
)

unless ENV['SKIP_FAKE_DATA']
  10.times do |i|
    BlogEntry.create!(
      author: "Adam Holland",
      title: "What we're reading, numbered ##{i}",
      url: 'http://www.example.com',
      published_at: Time.now
    )
  end

  20.times do |i|
    BlogEntry.create!(
      author: "Adam Holland",
      title: "A blog entry, numbered ##{i}",
      abstract: "An abstract of blog entry ##{i}",
      published_at: Time.now,
      topics: topics,
      content: %{
A blog entry ##{i}

* list item
* list item
* list item

1. ordered list item
2. ordered list item
3. ordered list item
4. ordered list item

`code formatting`

**bold**

> quoted paragraph
> quoted paragraph
> quoted paragraph
> quoted paragraph

## Heading 2
### Heading 3
#### Heading 4

    }
   )
  end
end
