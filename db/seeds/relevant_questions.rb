mapping = Hash.new { |hash,key| hash[key] = [] }

q = RelevantQuestion.create!(
 question: %{What rights are protected by copyright law?},
 answer:   %{The purpose of copyright law is to encourage creative work by granting a temporary monopoly in an author's original creations.  This monopoly takes the form of six rights in areas where the author retains exclusive control.  These rights are:

        (1) the right of reproduction (i.e., copying),
        (2) the right to create derivative works,
        (3) the right to distribution,
        (4) the right to performance,
        (5) the right to display, and
        (6) the digital transmission performance right.

The law of copyright protects the first two rights in both private and public contexts, whereas an author can only restrict the last four rights in the public sphere.  Claims of infringement must show that the defendant exercised one of these rights.  For example, if I create unauthorized videotape copies of <i>Star Trek II: The Wrath of Khan</i> and distribute them to strangers on the street, then I have infringed both the copyright holder's rights of reproduction and distribution.  If I merely re-enact <i>The Wrath of Khan</i> for my family in my home, then I have not infringed on the copyright.  Names, ideas and facts are not protected by copyright.

Trademark law, in contrast, is designed to protect consumers from confusion as to the source of goods (as well as to protect the trademark owner's market).  To this end, the law gives the owner of a registered trademark the right to use the mark in commerce without confusion.  If someone introduces a trademark into the market that is likely to cause confusion, then the newer mark infringes on the older one.  The laws of trademark infringement and dilution protect against this likelihood of confusion.  Trademark protects names, images and short phrases.

Infringement protects against confusion about the origin of goods.  The plaintiff in an infringement suit must show that defendant's use of the mark is likely to cause such a confusion.  For instance, if I were an unscrupulous manufacturer, I might attempt to capitalize on the fame of Star Trek by creating a line of 'Spock Activewear.'  If consumers could reasonably believe that my activewear was produced or endorsed by the owners of the Spock trademark, then I would be liable for infringement.

The law of trademark dilution protects against confusion concerning the character of a registered trademark.  Suppose I created a semi-automatic assault rifle and marketed it as 'The Lt. Uhura 5000.'  Even if consumers could not reasonably believe that the Star Trek trademark holders produced this firearm, the trademark holders could claim that my use of their mark harmed the family-oriented character of their mark.  I would be liable for dilution.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What kinds of things are copyrightable?},
 answer:   %{In order for material to be copyrightable, it must be original and must be in a fixed medium.

Only material that originated with the author can support a copyright. Items from the public domain which appear in a work, as well as work borrowed from others, cannot be the subject of an infringement claim. Also, certain stock material might not be copyrightable, such as footage that indicates a location like the standard shots of San Francisco in <i>Star Trek IV: The Voyage Home</i>. Also exempted are stock characters like the noisy punk rocker who gets the Vulcan death grip in <i>Star Trek IV</i>.

The requirement that works be in a fixed medium leaves out certain forms of expression, most notably choreography and oral performances such as speeches. For instance, if I perform a Klingon death wail in a local park, my performance is not copyrightable. However, if I film the performance, then the film is copyrightable.

Single words and short phrases are generally not protected by copyright, even when the name has been "coined" or newly-created by the mark owner.  Logos that include original design elements can be protected under copyright or under trademark.  Otherwise, words, phrases and titles may be protected only by trademark, however.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is copyright infringement?  Are there any defenses?},
 answer:   %{Infringement occurs whenever someone who is not the copyright holder (or a licensee of the copyright holder) exercises one of the exclusive rights listed <a href="#QID8">above</a>.  

The most common defense to an infringement claim is "fair use," a doctrine that allows people to use copyrighted material without permission in certain situations, such as quotations in a book review.  To evaluate fair use of copyrighted material, the courts consider four factors:<ol class=main>        
        <li> the purpose and character of the use
        <li> the nature of the copyrighted work
        <li> the amount and substantiality of copying, and 
        <li> the market effect.
</ol><p>(<a href="http://www4.law.cornell.edu/uscode/17/107.html">17 U.S.C. 107</a>)

The most significant factor in this analysis is the fourth, effect on the market.  If a copier's use supplants demand for the original work, then it will be very difficult for him or her to claim fair use.  On the other hand, if the use does not compete with the original, for example because it is a parody, criticism, or news report, it is more likely to be permitted as "fair use."  

Trademarks are generally subject to fair use in two situations:  First, advertisers and other speakers are allowed to use a competitor's trademark when referring to that competitor's product ("nominative use").  Second, the law protects "fair comment," for instance, in parody.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Do plot synopses and reproductions of photographs infringe on copyrights?},
 answer:   %{A plot synopsis may or may not infringe on a copyright, depending on whether the court finds that the use of original material is fair use.  Photographs are protected by the copyright holder's rights to both reproduce and display his work, and this right may be violated by posting those photographs on the Internet.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{How is Internet anonymity affected by John Doe lawsuits?},
 answer:   %{Often called "CyberSLAPP" suits, these lawsuits typically involve a person who has posted anonymous criticisms of a corporation or public figure on the Internet.  The target of the criticism then files a lawsuit so they can issue a subpoena to the Web site or Internet Service Provider (ISP) involved and thereby discover the identity of their anonymous critic.  The concern is that this discovery of their identity will intimidate or silence online speakers even though they were engaging in protected expression under the First Amendment. }
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{Why is anonymous speech important?},
 answer:   %{There are a wide variety of reasons why people choose to speak anonymously.  Many use anonymity to make criticisms that are difficult to state openly - to their boss, for example, or the principal of their children's school.  The Internet has become a place where persons who might otherwise be stigmatized or embarrassed can gather and share information and support - victims of violence, cancer patients, AIDS sufferers, child abuse and spousal abuse survivors, for example.  They use newsgroups, Web sites, chat rooms, message boards, and other services to share sensitive and personal information anonymously without fear of embarassment or harm. Some police departments run phone services that allow anonymous reporting of crimes; it is only a matter of time before such services are available on the Internet.  Anonymity also allows "whistleblowers" reporting on government or company abuses to bring important safety issues to light without fear of stigma or retaliation. And human rights workers and citizens of repressive regimes around the world who want to share information or just tell their stories frequently depend on staying anonymous &#8211; sometimes for their very lives.}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What is FanFic?},
 answer:   %{Fan Fiction (FanFic) is a genre of amateur creative expression that features characters from movies, TV shows, and popular culture in new situations or adventures. 

The vast majority of these stories and poems are written by fans with no commercial interest who disseminate their work over the Internet, email lists, or newsgroups. The word "Fan," however, might not be the most appropriate term since not all FanFic is created by people who are truly "fans" of the original work as the term is traditionally used. Regardless of whether FanFic authors are really fans, owners of original works often do not look favorably upon these works. In response, the owners of the rights often try to stop the creation of FanFic through cease and desist letters and the threat of lawsuit. }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Is anonymous speech a right?},
 answer:   %{Yes.  Anonymous speech is presumptively protected by the First Amendment to the Constitution.  Anonymous pamphleteering played an important role for the Founding Fathers, including James Madison, Alexander Hamilton, and John Jay, whose Federalist Papers were first published anonymously.  

And the Supreme Court has consistently backed up that tradition.  The key U.S. Supreme Court case is McIntyre v. Ohio Elections Commission.  <a href="http://www.eff.org/Legal/Cases/mcintyre_v_ohio.decision">http://www.eff.org/Legal/Cases/mcintyre_v_ohio.decision</a>}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the key federal decisions involving anonymous speech?},
 answer:   %{1.  <a href="http://supct.law.cornell.edu/supct/html/97-930.ZO.html">Buckley v. American Constitutional Law Foundation</a> (1999) 525 U.S. 182, 197-200; 

2.  <a href="http://www.eff.org/Legal/Cases/mcintyre_v_ohio.decision">McIntyre v. Ohio Elections Commission</a> (1995) 514 U.S. 334.  In that case, on page 357, the Supreme Court said:

 "[A]n author is generally free to decide whether or not to disclose his or her true identity. The decision in favor of anonymity may be motivated by fear of economic or official retaliation, by concern about social ostracism, or merely by a desire to preserve as much of one}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{How do CyberSLAPP plaintiffs discover the identity of anonymous Internet critics?},
 answer:   %{CyberSLAPP plaintiffs usually get the personal information you gave an ISP or online message board when you signed up (name, address, telephone number, etc.).  Some web sites that host discussion boards might only have your e-mail address, in which case a second subpoeana to the ISP that hosts that address will reveal your identity.  In many cases, even more detailed information about your use of the Internet can be obtained; it's important to realize that when you go online, you leave electronic footprints almost everywhere you go. (With advanced knowledge of the Internet, however, there are ways to cover your tracks.)
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{Don't judges review subpoenas before they are sent to ISPs?},
 answer:   %{No.  The issuing of civil subpoenas is not monitored by the court handling the case.  Under the normal rules of discovery in civil lawsuits, parties to a suit can simply send a subpoena to anyone they believe has information that could be useful.  That information doesn't even have to be relevant to the lawsuit, as long as it could possibly lead to the discovery of relevant information. The only way that a court will evaluate an identity-seeking subpena is if either the ISP or the target of the subpoena files a motion asking the judge to block the subpoena.  Unfortunately, in practice that rarely happens.  That is because these subpoenas usually have a short, roughly 7-day deadline, and because many people never even find out that their Internet data has been subpoenaed. 
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{Isn't my ISP required by law to tell me if someone asks for my Internet-usage records and identity?},
 answer:   %{Unfortunately, in practice CyberSLAPP subpenas are rarely challenged becaue ISPs often fail to notify the individual who's personal information is sought.  Even when they do, the short deadline (often as little as 7 days) does not provide enough time for the speaker to find and hire an attorney and the attorney to prepare the Constitutional arguments necessary to defend against the subpena.  }
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What should I do if I receive notice that my ISP has received a subpoena for my data?},
 answer:   %{First you should decide whether you wish to fight to protect your identity, Internet usage records, or whatever else is being sought.  You might want to ask your ISP for a copy of the subpoena if they haven't already provided one.  If you decide to fight it, you should inform the ISP immediately, and you may want to request that they delay compliance to give you time to find a lawyer.  Then find a lawyer, who will file a motion to have the subpoena thrown out.  (If your lawyer can later prove that the lawsuit was frivolous, you may be able to recover legal fees if your state has passed an anti-SLAPP statute.)

}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{How much time would I have to try to fight a subpoena?},
 answer:   %{The ISP's deadline for complying with a subpoena can vary depending on the judge, the jurisdiction where the case was filed, and other factors.  A typical deadline is 7 days.  This isn't much time, so again you may want to request an extension of the deadline from the ISP and the court so your lawyer can prepare your challenge to the subpoena. 

}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the typical claims behind a CyberSLAPP suit?},
 answer:   %{The most common complaints by CyberSLAPP plaintiffs are defamation, trademark or copyright infringement, and breach of contract.  Speech that involves a public figure - such as a corporation - is only defamatory if it is false and said with "actual malice." It also must be factual rather than an expression of opinion. In the US, because of our strong free speech protections, it is almost impossible to prove defamation against a public figure.  Trademark and copyright complaints typically claim that defendants have violated intellectual property rights by using the name of a corporation or its products, or by quoting from some of their copyrighted materials such as an annual report.  In reality, the First Amendment includes a clear right to criticize and discuss corporations and their products, and the law includes clear exceptions for the "fair use" of protected material for those purposes. Breach of contract suits often involve a claim that anonymous speakers might be employees who have violated a contract by releasing confidential information. Of course, the right to anonymous speech is meaningless if a corporation can unmask your identity at will because you might be an employee breaking a promise of confidentiality.
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{How do judges decide whether to let a subpoena go forward? },
 answer:   %{This is a very new area of the law, and there are few well-established principles.  The courts do have a duty to balance the right of anonymity against the need to prevent true defamation.  So far there have been both good and bad rulings from judges; fortunately several have ruled that the plaintiff must prove that his case has at least a theoretical chance of prevailing before anonymity can be stripped away.  Other cases have established a set of key factors to be used in judging anonymity-stripping subpoenas.  In most of these the key factors are 1) that the party seeking the subpoena provide evidence that the identity is needed; 2) that the identity is directly needed for a key element in the case; 3) and that the identity information is not otherwise available to the party seeking it. While not yet firmly entranched in the law, these common-sense principles are clearly the right way to ensure that First Amendment rights are protected while still allowing identity to be revealed when there is a genuine need to do so. 
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What are some of the important cases in this area of law?},
 answer:   %{Important CyberSLAPP cases include Dendrite v. Does, <a href="http://www.citizen.org/documents/dendriteappeal.pdf">http://www.citizen.org/documents/dendriteappeal.pdf</a>, 
Melvin v. Doe, <a href="http://legal.web.aol.com/decisions/dlpriv/melvinop.html">http://legal.web.aol.com/decisions/dlpriv/melvinop.html</a>,
Doe v 2TheMart.com, <a href="http://www.eff.org/Cases/2TheMart_case/20010427_2themart_order.html">http://www.eff.org/Cases/2TheMart_case/20010427_2themart_order.html</a>, 
Global Telemedia International v. Doe, <a href="http://www.casp.net/busted.html">http://www.casp.net/busted.html</a>.  Additional information about these and other cases can be found by searching the Internet or looking on the Web sites listed below. 
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I do anything to help change this situation? },
 answer:   %{You can do several things.  Be educated about your rights.   Find out your ISP's policy on the handling of subpoenas, and encourage them - and any Web sites you frequent - to adopt good policies, especially a pledge to notify you of any subpoena before any private information is disclosed.  Encourage your state legislators to pass legislation requiring such notice, and press them to amend state anti-SLAPP statutes to explicitly include Internet anonymity cases. 
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What other resources are available?},
 answer:   %{Web sites dealing with this issue include:

<a href="http://www.aclu.org">www.aclu.org</a>, 
<a href="http://www.citizen.org">www.citizen.org</a>, 
<a href="http://www.eff.org">www.eff.org</a>, 
<a href="http://www.epic.org">www.epic.org</a>, 
<a href="http://www.johndoes.org">www.johndoes.org</a>, 
<a href="http://www.casp.net">www.casp.net</a>, 
<a href="http://www.cybersecuritieslaw.com">www.cybersecuritieslaw.com</a>, 
<a href="http://cyber.findlaw.com/expression/censorship.html">cyber.findlaw.com/expression/censorship.html</a>
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{Can someone ask for my identity even if I am not the Defendant in the case?},
 answer:   %{Yes.  The rules of civil discovery allow a party to a lawsuit (the plaintiff or defendant) to ask anyone for any information that may lead to the discovery of relevant evidence to their case.  However, your ability to quash such a request if you are not named as a party to the lawsuit is the same as if you are named.  You can still file a motion to quash.  Below is a link to the case files for such a case:

http://www.eff.org/Cases/2TheMart_case/}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{I am in California.  Do I have a right to both resist such a subpena and to ask a court to throw out the case, right away, and award me attorneys fees?},
 answer:   %{Yes.  California has a specific statute, called the anti-SLAPP statute, that allows an early motion to be brought to have a case dismissed if it is aimed at silencing protected expression and participation in matters of public concern.

Code of Civil Procedure }
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Anti-Cybersquatting Consumer Protection Act (ACPA)?},
 answer:   %{The ACPA [codified as <a href="http://www4.law.cornell.edu/uscode/15/1125.html#d">15 USC 1125(d)</a>] is aimed at people who register a domain name with the intention of taking financial advantage of another's trademark. For instance, if BURGER KING did not have a web site, and you registered www.BURGERKING.com with the intent of selling the site to BURGER KING for a royal ransom, you could be liable under ACPA.

ACPA applies to people who: 
(1) have a bad faith intent to profit from a domain name; and 
(2) register, use or traffic in a domain name; 
(3) that is identical, confusingly similar, or dilutive of certain trademarks. The trademark does not have to be registered.

ACPA provides that cyberpirates can be fined between $1,000 and $100,000 per domain name for which they are found liable, as well as being forced to transfer the domain name.

Somewhat more broadly, the Act is meant to reduce consumers' confusion about the source and sponsorship of Internet web pages.  The idea is to provide customers with a measure of reliability, so that when they visit www.burgerking.com, they will be able to find actual Burger King products, not something entirely different.  It also protects mark owners from loss of customer goodwill that might occur if others used the trademark to market disreputable goods or services.

See the module on <!--GET CatLink 10--> to find out more about bad faith and legitimate defenses.
}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{Who can use the ACPA?},
 answer:   %{         The owner of any trademark protected under US federal law, whether registered or not, so long as the mark<br>
<ol><li>is distinctive at the time of registration of the domain name, or</li><li>is a famous mark at the time of registration, or </li><li>is a "mark, word or name" that is protected because it is reserved for use by the Red Cross or the U.S. Olympic Committee. </li>
</ol><br>}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{I registered the domain first.  Why can't I keep it?},
 answer:   %{        Maybe you can.  The ACPA only protects trademark owners against cybersquatters.  If your registration or use doesn't violate the Act, you should be able to keep the domain.  However, being the first to register a name doesn't give you special rights or protections if you violate the law.  Just as in physical space, you cannot use another's trademark to your own commercial advantage if the result is to "steal" the value of the trademark's goodwill and turn it to your own advantage.  Read the remaining FAQs that explain what the ACPA actually forbids.<br>
}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{How does the ACPA apply to domain names?},
 answer:   %{        It makes it illegal to register, "traffic in" or use a domain name is identical or confusingly similar to a distinctive or famous mark (or which dilutes a famous mark).
}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What does "distinctive" mean?},
 answer:   %{"Distinctive" is a term of art in trademark law and is determined by analyzing several factors.  Essentially, a mark is distinctive when the consumers have come to recognize it as the source or origin of certain goods or services.  Take the word "bronco": consumers recognize it as a brand of automobile; therefore it is distinctive as to automobiles.  But it is not distinctive as to horses, where it would be generic, nor as to baby diapers since there is no one offering such goods under that label.  Some words can never become distinctive as marks if they generically describe the very good or service for which they are used (i.e., one cannot trademark the word "basketball" to describe a brand of basketballs.)  In general, if a word has been in substantially exclusive and continuous use as a mark in commerce for five years, it will be deemed distinctive as to those goods/services <a href=&quot;http://www.bitlaw.com/source/15usc/1052.html#(f)&quot;>15 USC 1052(f)</a>.}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What does "traffics in" mean?},
 answer:   %{         According to the ACPA, it refers to "transactions that include, but are not limited to, sales, purchases, loans, pledges, licenses, exchanges of currency," and any other transfer for payment.  In other words, any transaction involving the domain name that generates value for the cybersquatter.}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What constitutes a violation of the Act?},
 answer:   %{        In addition to having a domain name that steps on the toes of an existing trademark as mentioned above, a person will be held liable only if he or she has a "bad faith intent to profit from the mark, including a personal name which is protected as a mark."  An example of a personal name that is protected as a mark would be the name of a Hollywood celebrity whose name is used as a trademark to identify his or her performance services.}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What constitutes "bad faith" use of a domain name?},
 answer:   %{The ACPA instructs the courts to consider a number of factors to determine the presence of bad faith. These are enumerated in the paragraphs below, but many involve new concepts that are rather vaguely defined.  It may take some time before courts decide exactly how these new terms should be interpreted.
<ol>
<li>A court is likely to decide that a domain name registrant acquired or used the name in bad faith if s/he sought to divert customers from a trademark owner's website to another that, either for purposes of commercial gain or to tarnish the mark, could harm the goodwill represented by the mark.  "Goodwill" is a legal term indicating the valuable relationship or familiarity that exists between businesses and their customers and is often embodied in their trademark symbols.  It can be harmed if the domain name is likely to cause confusion about what organization created or sponsored a website.  Bad faith from attempted commercial gain can arise if a domain name holder steals customers because the name is so similar to a trademark.  For example, a shoe retailer might hold www.reabok.com, hoping to steal shoe buyers from customers looking for Reebok shoes.  Bad faith from tarnishing can arise if a domain name similar to a trademark leads web surfers to a site, such as a pornographic website, that tends to harm the "good name" of the trademark owner.  Or a pornographic website at www.reabok.com could create an unwholesome association that Reebok would like to avoid.  (Although, Reebok may be considered a famous mark}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{How do I know which marks are famous and what difference does it make?},
 answer:   %{Owners of "famous" marks have special privileges.  They can block new uses of any similar name even if consumers wouldn't be confused by it.  They are protected against "dilution" and "tarnishment" as well.

If you walk up to someone on the street and ask someone if they recognize the word or symbol, and they recognize it right away, it is probably famous.  If you have to remind them ("The Berkman Center is this crazy thing at Harvard}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{Is it possible to hold a domain name in good faith even if it is identical or confusingly similar to another's trademark?},
 answer:   %{The ACPA is forgiving of legitimate uses of domain names.  There is less likely to be a violation of the Act if the domain name holder actually has some intellectual property rights in the name, or if the person has previously used the domain name in connection with bona fide offering of goods or services.  Operating a domain name to which you have fairly entrenched trademark rights, or having operated a sales website under the domain name for a long time, is somewhat safer. 

Take note, however, that this safety is illusory if your domain name resembles (or is) a famous mark.  Thus an Internet service provider, Virtual Works, lost a case to Volkswagen, over its domain name www.vw.net, because the "VW" mark is famous, even though VW is the abbreviation of Virtual Works, and even though they had operated the site for several years. 

If your domain name is your own name, or a name by which you are often referred, this is more likely to be deemed a good faith use.  Edwin Von Aschenbach will probably be safe in registering www.vonaschenbach.com, even if Von Aschenbach, Co., manufactures high quality desks and "Von Aschenbach" is a trademark in the sale of desks.  Edwin Pepsy should be more careful.}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What about noncommercial uses?},
 answer:   %{      According to the Fourth Circuit Court of Appeals, "the Federal Trademark Dilution Act of 1995 ("FTDA") and the Anticybersquatting Consumer Protection Act of 1999 ("ACPA"), Congress left little doubt that it did not intend for trademark laws to impinge the First Amendment rights of critics and commentators. The dilution statute applies to only a 'commercial use in commerce of a mark,' 15 U.S.C. }
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What if I think that my domain name is OK?  Am I still in trouble?},
 answer:   %{The ACPA provides that there is no bad faith if the domain name holder believes, and had reasonable grounds to believe, that his or her use of the domain name was a fair use or otherwise lawful.  It is not so clear that this provision will really keep you out of trouble.  However, in doubtful cases, if you are using a domain name in which you have some intellectual property rights, and under which you have sold goods or services, and if someone else claims infringement upon a slightly-but-not-very famous mark, it might be of some use as an additional factor in your favor. }
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What if I don't live in the US?  Can I still lose my domain name under the ACPA?},
 answer:   %{ Indeed, you can.  If the mark owner is protected by US law (uses the mark in the US) then that mark owner can bring an ACPA action in a US court regardless of the domain holder's location.  If the domain holder fails to show up in court, s/he may lose by default, in which case the US court will issue an order to the domain registrar or registry to cancel or transfer the domain registration to the mark owner.  If the domain holder cannot be identified or located, the mark owner can bring an in rem action to obtain the domain name (see <a href=&quot;#QID47&quot;>"What if the mark owner can't find the domain name holder?")</a>. But the court must have authority over the registry or registrar holding the domain registration.  All .com, .org and .net domain names are subject to the ACPA because the registry, Network Solutions, is located in the US.  If the court does not have jurisdiction over the domain name registrar or registry, however, it will be difficult for the court to enforce its order outside the US. If neither the domain holder nor the mark owner has any contact in the US, then it isn't likely either can seek protection under US domestic laws, however, this is a question decided under treaties that govern international protection of trademarks.  In such cases, the UDRP may be a more useful forum for the trademark owner to use.
}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{How does a mark owner use the ACPA against cybersquatters?},
 answer:   %{ The ACPA creates a private right of action for trademark owners.  This means that the owner of a trademark can sue the holder of a confusingly similar domain name.  The suit must be brought in Federal Court - in a U.S. District Court.  <br>
     <dd>To summarize what has been said above }
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What if the mark owner can't find the domain name holder?},
 answer:   %{ The mark owner can bring suit in the judicial district in which the domain name registration authority (registrar or registry) which registered the domain name is located either if the court there finds that it does not have jurisdiction over the domain name holder in person, or if the domain holder cannot be located.   <br>
      <dd>To claim that a mark owner "can't find" the domain name holder, s/he must first try, by sending notice - of the alleged violation and intent to sue - to the domainholder's postal and e-mail addresses as provided by the holder to the registrar, and, by publishing notice of the suit as the court deems appropriate.  <br>
      <dd>Then, if the mark owner really can't find the domain name holder, s/he can bring an <i><b>in rem suit</b></i> against the domain name itself.  This means that the suit is formally on the thing itself - the domain name - and not against the holder.  In such a suit, the court may either cancel the registration of the domain name, or order its transfer to the mark owner, but may not award any money damages. }
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the possible penalties for violating the ACPA?},
 answer:   %{Normally, the domain name holder will not evaporate, and can be sued directly.  In such a case, the court can order the cancellation or transfer of the domain registration, as well as require the payment of money damages to the plaintiff trademark owner.  

The trademark owner can recover (1) the domain holder's profits from use of the mark, (2) the trademark owner's damages resulting from harm to the value of mark, and (3) court costs as "actual damages."  In determining the award to be paid, the court can choose to award up to three times the amount of actual damages.  Attorney fees may be awarded in exceptional circumstances, such as when there was a willful and malicious violation.

Instead of having to prove the amount of "actual" damages suffered as above, the mark owner can instead request payment of "statutory damages" from $1000 and $100,000 per domain name. }
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{I'm a web designer and I posted the site at the direction of my client. Am I liable under the ACPA?},
 answer:   %{A person shall be liable under the ACPA for using a domain name under subparagraph only if that person is the domain name registrant or that registrant's authorized licensee.  

However, for use of trademarks elsewhere on the site (in metatags or in the page content, for example) be aware that there may still be a risk of liablity as a trademark infringer or contributing infringer.  The protections offered to }
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{Are domain name registration authorities liable under the Act?},
 answer:   %{A domain name registration authority is not liable for money damages for the registration or maintenance of a domain name for another absent a showing of bad faith intent to profit from such registration or maintenance.<br>
      <dd>A domain name registration authority is subject to court injunction if it refuses to provide the court with documentation concerning the domain name that would establish the court's control over it in an <a href="#find">in rem</a> suit, or if it transfers, changes, or cancels the domain name during an in rem suit.  
   </dd>}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{What can be protected as a trademark?},
 answer:   %{.
You can protect <UL>
<LI>names (such as company names, product names)</li>
<LI>domain names if they label a product or service</li>
<LI>images</li>
<LI>symbols</li>
<LI>logos</li>
<LI>slogans or phrases</li>
<LI>colors</li>
<LI>product design</li>
<LI>product packaging (known as <B>trade dress</b>)</li>
</ul>
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trade dress?},
 answer:   %{The term, trade dress, originally referred to a product's packaging.  A trade dress extends to the total image of a product or service.  }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What exactly are the rights a trademark owner has?},
 answer:   %{In the US, trademark rights come from actual use of the mark to label one's services or products or they come from filing an application with the Patent and Trademark Office (<B>PTO</b>) that states an intention to use the mark in future commerce. In most foreign countries, trademarks are valid only upon registration.

There are two trademark rights: the <B>right to use</b> (or authorize use) and the <B>right to register</b>. 

The person who establishes priority rights in a mark gains the exclusive right to <b>use</b> it to label or identify their goods or services, and to authorize others to do so. According to the Lanham Act, determining who has priority rights in a mark involves establishing who was the first to use it to identify his/her goods.  

The PTO determines who has the right to <b>register</b> the mark. Someone who registers a trademark with the intent to use it gains <B>"constructive use"</b> when he/she begins using it, which entitles him/her to nationwide priority in the mark. However, if two users claim ownership of the same mark (or similar marks) at the same time, and neither has registered it, a court must decide who has the right to the mark. The court can issue an <B>injunction</b> (a ruling that requires other people to stop using the mark) or award damages if people other than the owner use the trademark (<A href="#infringe"><B>infringement</b></a>).<P>

Trademark owners do not acquire the exclusive ownership of words.  They only obtain the right to use the mark in commerce and to prevent competitors in the same line of goods or services from using a confusingly similar mark. The same word can therefore be trademarked by different producers to label different kinds of goods.  Examples are Delta Airlines and Delta Faucets.

Owners of famous marks have broader rights to use their marks than do owners of less-well-known marks.  They can prevent uses of their marks by others on goods that do not even compete with the famous product.
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Do I have to register my brand name to get trademark rights?},
 answer:   %{Not in the United States.  Here, you do not need to register a mark to establish rights to it, though registration provides important advantages. Registering a mark means that the registrant is presumed to be the owner of the mark for goods and services specified in the application. This makes proving your rights easier in court.  

However, US federal law also provides rights to unregistered (<B>}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What implication does alleged confusion have on claims of trademark infringement?},
 answer:   %{.
A mark that is <B>confusingly similar</b> so closely resembles a registered trademark that it is likely to confuse consumers as to the source of the product or service. Consumers could be likely to believe that the product with the confusingly similar mark is produced by the organization that holds the registered mark. Someone who holds a confusingly similar mark benefits from the good will associated with the registered mark and can lure customers to his/her product or service instead. <A NAME=infringe></a><B>Infringement</b> is determined by whether your mark is confusingly similar to a registered mark.  The factors that determine infringement include:<UL>
<LI>proof of actual confusion</li>
<LI><a href="http://www.chillingeffects.org/trademark/faq.cgi#QID252">strength</a> of the established mark</li>
<LI>proximity of the goods in the marketplace</li>
<LI>similarity of the marks? sound</li>
<LI>appearance and meaning</li>
<LI>how the goods are marketed</li>
<LI>type of product and how discerning the customer is</li>
<LI>intent behind selecting the mark</li>
<LI>likelihood of expansion in the market of the goods</li>
</ul>


}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{How long do trademark rights last?},
 answer:   %{.
Trademark rights can last indefinitely if the trademark owner continues to use the mark to identify goods or services. According to the <A HREF="http://www.uspto.gov/">PTO website</A>, }
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{How do I register a trademark?},
 answer:   %{.
There are three ways to register:<OL>
<LI>file a <B>use application</B>, which lets someone who is already using the mark register it,</LI>
<LI>file an <B>intent to use application</B>, which states that you honestly intend to use the mark in commerce. The mark must be associated with commerce, instead of simply being a mark that you want to reserve. Merely using the mark in advertising or promotion does not qualify under this category -- the use must be associated with an actual commercial purpose, or</LI>
<LI>(non-US applicants only) file based on an existing foreign registration.</LI>
</OL>

All applications require a fee. Remember that it is not necessary to register a trademark to gain protection in the United States. <p>
Four months after registration, the trademark application is examined by an attorney at the PTO. The attorney determines whether the mark is registerable. If not, the applicant receives a letter stating the grounds for refusal and information on needed corrections (if applicable). If the attorney requests additional information, the applicant has six months to respond; after six months, the application is deemed abandoned. <p>
The most common reason for being unable to register is that the mark is confusingly similar to an existing mark. If the attorney finds a conflicting mark and cannot grant the application, the PTO does not refund the application fee. <p>
If the mark can be registered and the application passes, the attorney approves the mark for publication in the PTO}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the limits of trademark rights?},
 answer:   %{.
There are many limits, including:<UL>
<LI>Fair Use<BR>There are two situations where the doctrine of <B>fair use</b> prevents infringement:<OL>
<LI>The term is a way to describe another good or service, using its descriptive term and not its secondary meaning. The idea behind this fair use is that a trademark holder does not have the exclusive right to use a word that is merely descriptive, since this decreases the words available to describe.  If the term is not used to label any particular goods or services at all, but is perhaps used in a literary fashion as part of a narrative, then this is a non-commercial use even if the narrative is commercially sold.  </li>
<LI>Nominative fair use<BR> This is when a potential infringer (or defendant) uses the registered trademark to identify the trademark holder's product or service in conjunction with his or her own. To invoke this defense, the defendant must prove the following elements:<UL>
<LI>the product or service cannot be readily identified without the mark</li>
<LI>he/she only uses as much of the mark as is necessary to identify the goods or services</li>
<LI>he/she does nothing with the mark to suggest that the trademark holder has given his approval to the defendant</li></ul></ol>
<LI>Parody Use<BR>Parodies of trademarked products have traditionally been permitted in print and other media publications.  A parody must convey two simultaneous -- and contradictory -- messages: that it is the original, but also that it is not the original and is instead a parody.</li>
<LI>Non-commercial Use<BR>If no income is solicited or earned by using someone else's mark, this use is not normally infringement. Trademark rights protect consumers from purchasing inferior goods because of false labeling. If no goods or services are being offered, or the goods would not be confused with those of the mark owner, or if the term is being used in a literary sense, but not to label or otherwise identify the origin of other goods or services, then the term is not being used commercially. </li>
<LI>Product Comparison and News Reporting<BR>Even in a commercial use, you can refer to someone else?s goods by their trademarked name when comparing them to other products. News reporting is also exempt.</li>
<LI>Geographic Limitations<BR>A trademark is protected only within the geographic area where the mark is used and its reputation is established.  For federally registered marks, protection is nationwide. For other marks, geographical use must be considered. For example, if John Doe owns the mark <I>Timothy's Bakery</i> in Boston, there is not likely to be any infringement if Jane Roe uses <I>Timothy's Bakery</i> to describe a bakery in Los Angeles.  They don't sell to the same customers, so those customers aren't confused.</li>
<LI>Non-competing or Non-confusing Use<BR>
Trademark rights only protect the particular type of goods and services that the mark owner is selling under the trademark.  Some rights to expansion into related product lines have been recognized, but generally, if you are selling goods or services that do not remotely compete with those of the mark owner, this is generally strong evidence that consumers would not be confused and that no infringement exists. This defense may not exist if the mark is a famous one, however. In dilution cases, confusion is not the standard, so use on any type of good or service might cause infringement by dilution of a famous mark. </LI>
</ul>
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Why do trademark owners worry about meta tags?},
 answer:   %{.
A <B>meta tag</B> on a Web page stores key words describing the Web site to a search engine for use when someone searches for one of those keywords. Some courts have held that it is trademark infringement when one company uses another}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the UDRP?},
 answer:   %{   The Uniform Domain Name Dispute Resolution Policy (}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the UDRP and ACPA?},
 answer:   %{Follow these links for Frequently Asked Questions on the <!--GET FAQLink 9--> (Uniform Domain Name Dispute Resolution Policy) or <!--GET FAQLink 10--> (Anti-cybersquatting Consumer Protection Act).}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What&#8217;s in it for me?},
 answer:   %{   If you are a trademark owner, the UDRP may provide a faster, cheaper, and easier alternative to filling your complaint with a court of law.  If you are a domain name holder, you became bound by ICANN's UDRP when you registered the domain name.  The Registration Agreement (to which you agreed with a mouse click) incorporates the UDRP.  Therefore, if your domain name is later challenged, you must submit to a "mandatory administrative proceeding" to determine rights to the domain.  It does not matter whether the trademark owner and domain name holder live in different countries.  Your domain registrar (from whom you obtained the domain) has the power and obligation to enforce the decision of the UDRP Panel.  If you refuse to participate, the proceeding may continue without you and your domain could be cancelled or transferred without your input.  }
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Why not go to court?},
 answer:   %{   As mentioned above, the UDRP is supposed to provide a faster, cheaper, and easier alternative to challenging domain names in courts of law.  Unless the domain holder fails to appear in court, it is likely that the UDRP proceeding will take less time (about 6 weeks).  UDRP proceedings generally cost less (as little as $750) since the dispute resolution Providers charge a flat fee and since the costs of hiring a lawyer (if you choose to use one) will generally be less because the types of documents used in UDRP proceedings require less time to prepare.  The UDRP procedures are supposed to be simple enough that an average person would not need legal assistance.  There is no charge to the domain holder, unless s/he requests a 3-person Panel or opts to hire an attorney.  An important advantage of the UDRP over courts is that courts can only enforce their orders within their own territories.  The UDRP can be enforced against all domain holders in .com, .org, .net. .biz and .info, regardless of where they live.
 
        Of course, nothing in the UDRP prevents either the trademark owner or the domain name holder from choosing to go to court before, during, or after the UDRP proceeding.  You just have to let the Panel know if you have begun court action so the Panel can decide whether to postpone the proceeding or so that the Registrar won}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{How was I supposed to know that my domain violates somebody else},
 answer:   %{It is the domain name registrant}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Why do trademarks get such special protection?},
 answer:   %{   Consumers reap the benefit when trademarks are protected.  By preventing anyone but the actual mark owner from labeling goods with the mark, it helps prevent consumers getting cheated by shoddy knock-off imitators.  It encourages mark owners to maintain quality goods so that customers will reward them by looking for their label as an indication of excellence.  Consumers as well as mark owners benefit from trademark laws.
 
        Trademark owners spend a lot of time, money, and effort to protect the distinctiveness of their trademark.  Once trademarks have become diluted to the point where the general public no longer recognizes them as distinctly applying to a particular manufacturer, they lose their value to the trademark owner because they no longer attract customers to his particular goods. For example, }
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Isn},
 answer:   %{Yes, as long as you have registered and used the domain name in good faith or have legitimate interests in the domain name.  However, you have no right to violate trademark law, or ignore your Registration Agreement, or engage in cybersquatting just because you registered the name first. 
}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I lose a domain registration in a UDRP?},
 answer:   %{   The trademark owner must prove three things: (1) that s/he has a trademark right that is identical or confusingly similar to your domain, (2) that you have no right or legitimate interest in the domain name, and (3) that you registered and used the domain in bad faith.}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a protectable "right or legitimate interest" in a domain name?},
 answer:   %{   If the domain holder has a right or legitimate interest in the domain name, then s/he is entitled to keep it, under the UDRP.  The Policy gives some examples of rights and legitimate interests, but the contestants and Panelists may develop others.  The Policy recognizes a right if (a) you are commonly known by the domain name (as a personal or business name), (b) if you are using it for legitimate noncommercial or fair uses without intent to mislead consumers or tarnish the mark owner (for example if the term is being used to generically describe what the website is about, such as }
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "bad faith" registration or use?},
 answer:   %{   Facts that are considered as evidence of bad faith are described in the UDRP Policy.  They include acquiring the domain name primarily for the purpose of selling or renting it to the mark owner (or the mark owner}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Who are the UDRP "Providers"?},
 answer:   %{           The Providers are organizations that have been approved by ICANN to resolve <!--GET CatLink 9-->
disputes. The four are:  World Intellectual Property Organization ("WIPO"); eResolution Consortium ("eRes"); the National Arbitration Forum ("NAF"); and CPR Institute for Dispute Resolution ("CPR").  Since the trademark owner chooses the Provider, the trademark owner should be aware that the Providers differ in some respects.  For example, each one may have its own supplemental rules, charge different fees, or have different page restrictions for the complaint and response.  Relative to each other, some providers are statistically more inclined to favor the trademark owner.   }
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Who are the UDRP "Panelists"?},
 answer:   %{   The Panelists "judge" the UDRP disputes and determine what happens to the domain name.  They include practicing attorneys, law professors, and former judges.  Each Provider maintains a list of eligible panelists and their qualifications.  Panelists are required to be impartial.  However, panelists may have certain biases (such as those who interpret the Policy conservatively to restrict its use to specific types of cybersquatting), so parties may wish to research the statistics on how any given panelist has decided disputes in the past.  Such information is available at <a href="http://www.UDRPinfo.com">http://www.UDRPinfo.com</a>.

        If neither the trademark owner nor the domain name holder has elected a three-member Panel the Provider chooses a single Panelist from its list of panelists.  If either the trademark owner or the domain name holder chooses to have the dispute decided by a three-member Panel, then the parties themselves have a voice in the selection of the Panelists.  In these cases, the Provider chooses one Panelist from the trademark owner}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the consequences of the proceeding?},
 answer:   %{   The Panel may cancel a domain name or order the transfer of the registration to the trademark owner or decide to leave the registration with the domain holder.  If it cancels the domain registration, the domain will go back on the market for anyone to grab, so this is not an option that most trademark owners would request.  If the domain name holder loses, the Registrar will wait 10 business days before implementing the Panel}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Reverse Domain Name Hijacking?},
 answer:   %{Trademark owners may not file complaints just to harass domain name holders.  Under the Policy, trademark owners who file complaints in bad faith are said to have engaged in "Reverse Domain Name Hijacking."  It is considered an abuse of the administrative proceeding and the Panel can enter such a finding in the record to warn others about such a trademark owner. 
}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a domain name holder bring a UDRP complaint to establish his or her right to the domain name?},
 answer:   %{No. Only mark owners can start a UDRP proceeding. A domain holder must file for a protective restraining order or declaratory judgement in a court of law.}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I get more information?},
 answer:   %{The following websites provide basic information related to the UDRP:
<p>
The UDRP Policy: <a href="http://www.icann.org/udrp/udrp-policy-24oct99.htm">http://www.icann.org/udrp/udrp-policy-24oct99.htm</a>
The UDRP Rules of Procedure: <a href="http://www.icann.org/udrp/udrp-rules-24oct99.htm">http://www.icann.org/udrp/udrp-rules-24oct99.htm</a>
Asian Domain Name Dispute Resolution Centre: <a href="http://www.hkiac.org/main.html">http://www.hkiac.org/main.html</a>
CPR Institute for Dispute Resolution: <a href="http://www.cpradr.org/home1.htm">http://www.cpradr.org/home1.htm</a> 
The National Arbitration Forum: <a href="http://www.arbforum.com/">http://www.arbforum.com/</a>
World Intellectual Property Organization <a href="http://arbiter.wipo.int/domains/">http://arbiter.wipo.int/domains/</a>}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Do fan fiction writers have a free speech right to publish their work?},
 answer:   %{The First Amendment protects free speech, but there is also a copyright clause in the Constitution. These two legal rights are often in conflict, and so the rights of fan fiction writers to write and speak freely and the rights of the copyright owner must be balanced. Each situation can be researched and individually evaluated, but it is important to understand there are no easy answers as to who has a right to the characters.
Copyright law is designed to encourage authors to be creative by rewarding their efforts and protecting their work from others who might profit unfairly. This right must be balanced by society's need to have others not be limited by previously published protected works. There is not a clear "right" and "wrong" side in the battle between copyright owners and fan fiction writers.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What are Chilling Effects? },
 answer:   %{"Chilling Effects" refers to the deterrent effect of legal threats or posturing, largely cease and desist letters independent of litigation, on lawful conduct.  The Chilling Effects clearinghouse will catalogue cease and desist notices and present analyses of their claims to help recipients resist the chilling of legitimate activities (as well as understand when their activities are unlawful).  The project's core, this database of letters and FAQ-style analyses is supplemented by legal backgrounders, news items, and pointers to statutes and caselaw.  Periodic "weather reports" will sum up the legal climate for online activity.}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Chilling Effects clearinghouse? },
 answer:   %{The project invites recipients and senders of cease and desist notices to send them to a central point (here, at chillingeffects.org) for analysis, and to browse the website for background information and explanation of the laws they are charged with violating or enforcing.  Clinical law students will prepare issue-spotting analyses of the letters in the question-and-answer style of FAQs, which we will post alongside the letters in an online database.  The site aims to educate C&D recipients about their legal rights.  Site visitors may search the database by subject area or keyword.

For more, see <a href="/about">about the Chilling Effects project</a>.}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a trademark?},
 answer:   %{A trademark is a "mark" (word, phrase, symbol, design, mark, device, or combination thereof) used to identify the source of a product.  Trademarks allow consumers to evaluate products before purchase.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a famous mark?},
 answer:   %{A famous mark is a mark that has become so well known, that it has become almost universally recognized. An example of such a mark would be "McDonald's" or "Coca-Cola." Famous marks become important where an owner of a trademark is claiming trademark dilution against a defendant. The Federal Anti-Dilution Act of 1996 provides that an owner of a famous mark is entitled to an injunction where a defendant's use of the mark causes dilution of the distinctive quality of the owner's famous mark. In determining whether a mark is famous, a court will consider a list of eight factors, found in the 1996 Federal Anti-Dilution Act.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trademark infringement?},
 answer:   %{Although different courts have different tests, the central concept is confusion in the marketplace.  The law protects against consumer confusion by ensuring that the marks on the same or similar products or services are sufficiently different.  A plaintiff in a trademark infringement case generally must prove  1) it possesses a valid mark; 2) that the defendant used the mark; 3) that the defendant used the mark in commerce, "in connection with the sale, offering for sale, distribution or advertising "of goods and services; and  4) that the defendant used the mark in a manner likely to confuse consumers.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is false designation of origin?},
 answer:   %{It covers similar ground to trademark infringement, but is more specific to misrepresentation of source, and applies even when there is no trademark at issue.  If your website makes it appear that you sell products made by Company X, but in fact you make these products in your garage, Company X might accuse you of falsely designating the origin of (or "passing off") your items.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trademark dilution?},
 answer:   %{A type of infringement of a famous trademark in which the defendant's use, while not causing a likelihood of confusion, tarnishes the image or blurs the distintiveness of the plaintiff's mark. For example, if someone tries to sell "KODAK" pianos, KODAK could stop the person--even if consumers were not confused--because "KODAK" is a famous mark, and its use on products other than film and film-printing accessories (or other products on which Eastman Kodak places the mark) dilutes its uniqueness. 

Many states have anti-dilution laws.  The federal government only recently enacted anti-dilution legislation; see the <a href="http://www4.law.cornell.edu/uscode/15/1125.html">Federal Trademark Dilution Act at 15 USC 1125(c)</a>.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is unfair competition?},
 answer:   %{"Unfair competition" covers a wide range of kinds of unjust business behavior---so many kinds, in fact, that it is impossible to give one simple general definition.  In essence, unfair competition means trademark infringement or false advertising to confuse the public.  In most states, only commercial competitors can be engaged in "unfair competition."  }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is copyright protection?},
 answer:   %{.
A copyright protects a literary, musical, dramatic, choreographic, pictoral
or graphic, audiovisual, or architectural work, or a sound recording, from
being reproduced without the permision of the copyright owner. <a HREF="http://cyber.law.harvard.edu/property/library/copyrightact.html#anchor534533">17
U.S.C. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the UDRP (Uniform Domain Name Dispute Resolution Policy)?},
 answer:   %{The UDRP was approved by the Internet Corporation for Assigned Names and Numbers ("ICANN") in 1999.  It is an online procedure for resolving complaints made by trademark owners about domain names.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What must a trademark owner prove to win a UDRP proceeding against a domain name holder?},
 answer:   %{     In order to win a UDRP proceeding against a domain name holder, the trademark owner must prove ALL of the following: 
1) that the domain name registered by the domain name holder is the same or confusingly similar to a trademark or service mark in which the trademark owner has rights.  UDRP decisions have gone both ways on whether a protest, criticism or parody site is confusingly similar when a domain name consists of the trademark and another word such as "sucks."  The most important factor seems to be whether or not the domain name owner is using the site for commercial purposes.  If it is, the panel will probably find that the use of the trademark in the domain name causes a likelihood of confusion.      
2) that the domain name owner does not have a legitimate interest in the domain name.  If the domain name owner's site is being used to criticize, protest or parody the trademarked entity or its owner's products and/or services, the panel will probably find that the domain name owner has a legitimate interest in the domain name.  This will probably be true, even if the domain name is, for all practical purposes, the same exact thing as the trademarked word.  
3) that the domain name owner has used and registered the domain name in bad faith.  Bad faith can be found in any number of factors including, but not limited to a) registration for the purpose of selling the domain name to the trademark owner for profit; b) a pattern of registration to prevent the trademark owner from using the mark in a domain name; c) registration for the primary purpose of disrupting the business of a competitor, or d) an intentional attempt to attract, for commercial gain, Internet users to the domain name owner's web site by creating a likelihood of confusion as to the source of a product or service on the domain name owner's website.  One clear example of bad faith would be where the domain name owner creates a site that contains ads advertising the goods or services of the competitors of the trademark owner.
     Remember, that to prevail under the UDRP, the trademark owner must prove all of the points listed above.
  
}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What type of relief can be obtained through a UDRP proceeding?},
 answer:   %{There can be three outcomes:  1) the trademark owner wins and the domain name is transferred to the trademark owner;  2) the trademark owner wins and the domain name is canceled; or 3) the domain name owner wins and keeps the domain name.
There is no appeal under the UDRP process, but you can file a lawsuit if you believe your rights have been violated.  If a timely lawsuit is filed (within 10 business days), there will be no action taken until the parties settle, the lawsuit is dismissed or withdrawn or there is a court order regarding the ownership of the domain name. }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is an "innocent fan fiction?"},
 answer:   %{[not yet answered]}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an opinion be defamatory?},
 answer:   %{No ? but merely labeling a statement as your "opinion" does not make it so. Courts look at whether a reasonable reader or listener could understand the statement as asserting a statement of verifiable fact. (A verifiable fact is one capable of being proven true or false.) This is determined in light of the context of the statement. A few courts have said that statements made in the context of an Internet bulletin board or chat room are highly likely to be opinions or hyperbole, but they do look at the remark in context to see if it's likely to be seen as a true, even if controversial, opinion ("I really hate George Lucas' new movie") rather than an assertion of fact dressed up as an opinion ("It's my opinion that Trinity is the hacker who broke into the IRS database").}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean to be directly liable?},
 answer:   %{Direct liability is where the person or organization is held responsible for its own actions or failure to act.  Contrast this with vicarious liability, where the person or organization is held responsible for harm caused by other persons (e.g. agents).}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is libel per se?},
 answer:   %{.
When libel is clear on its face, without the need for any explanatory
matter, it is called libel per se. The following are often found to be
libelous per se:
<br><br>
A statement that falsely:

<ul>
        <li> Charges any person with crime, or with having been indicted, convicted, or punished for crime; </li>
        <li> Imputes in him the present existence of an infectious, contagious, or loathsome disease; </li>
        <li>
Tends directly to injure him in respect to his office, profession,
trade or business, either by imputing to him general disqualification
in those respects that the office or other occupation peculiarly
requires, or by imputing something with reference to his office,
profession, trade, or business that has a natural tendency to lessen
its profits; </li>
        <li> Imputes to him impotence or a want of chastity.</li>

</ul>
Of course, context can still matter. If you respond to a post you don't
like by beginning "Jane, you ignorant slut," it may imply a want of
chastity on Jane's part. But you have a good chance of convincing a
court this was mere <a href="http://snltranscripts.jt.org/78/78oupdate.phtml">hyperbole and pop cultural reference</a>, not a false statement of fact.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is defamation?},
 answer:   %{An attack by speech on the good reputation of a person or business entity.  Speech that involves a public figure--such as a corporation--is only defamatory if it is false and said with actual malice.  It also must be factual rather than an expression of an opinion.  In the United States, because of our strong free speech protections, it is almost impossible to prove defamation of a public figure. }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the right of publicity?},
 answer:   %{The right of publicity is a right to prevent the unauthorized commercial use of someone's identity, including name, image, or likeness.  A natural person (and that person}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the DMCA's anti-circumvention provisions?},
 answer:   %{<p>The Digital Millennium Copyright Act (DMCA) is the latest amendment to copyright law, which introduced a new category of copyright violations that prohibit the "circumvention" of technical locks and controls on the use of digital content and products.  These anti-circumvention provisions put the force of law behind any technological systems used by copyright owners to control access to and copying of their digital works.</p>

<p>The DMCA contains four main provisions: 
<ol><li>a prohibition on circumventing access controls <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a">[1201(a)(1)(A)]</a>; 
<li>an access control circumvention device ban (sometimes called the "trafficking" ban) <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a2">[1201(a)(2)]</a>; 
<li>a copyright protection circumvention device ban <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#b">[1201(b)]</a>; and, 
<li>a prohibition on the removal of copyright management information (CMI) [1202(b)].</ol></p>

<p>The first provision prohibits the act of circumventing technological protection systems, the second and third ban technological devices that facilitate the circumvention of access control or copy controls, and the fourth prohibits individuals from removing information about access and use devices and rules. The first three provisions are also distinguishable in that the first two provisions focus on technological protection systems that provide access control to the copyright owner, while the third provision prohibits circumvention of technological protections against unauthorized duplication and other potentially copyright infringing activities.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Why was the DMCA passed?},
 answer:   %{<p>The stated purpose of the DMCA is to ensure the protection of copyright works in the digital world by fortifying the technological blocks on access and copying of those works within a legal framework. This amendment to title 17 (the Copyright Act) was signed into law on October 28, 1998 as the United States implementation of the World Intellectual Property Organization (WIPO) Copyright Treaty adopted by countries around the world two years earlier.  The DMCA implemented these recommendations in a much stricter fashion than required, giving copyright owners broader protection than was intended in the international treaty.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{So what is all the controversy about the DMCA?},
 answer:   %{<p>The shift towards the distribution of copyrighted materials in digital form has been accompanied by new methods of protection.   Through the use of "digital locks," technological systems behind which these copyrighted materials are protected, producers and manufacturers are able to automate fine grained control over who can access, use, and/or copy their works and under what conditions. Producers insist these "digital locks" are necessary to protect their materials from being pirated or misappropriated. But, these new technological systems, and the DMCA provisions making it a crime to bypass them, undermine individuals ability to make "fair use" of digital information, and essentially replace the negotiation of the terms of use for those products with unilateral terms dictated by copyright owners.  These self-help technical protection mechanisms are generally not evident to the purchaser or user until after the sale.  In some cases, producers who use these technical locks to enforce limits on access and use of their works fail to disclose the terms of use to the purchasers or licensees of their products.</p>

<p>The defenses and exemptions to the circumvention prohibition and circumvention device bans included in the law are fatefully narrow. As a result, the legitimate activities of scientists, software engineers, journalists, and others have been chilled. The DMCA has been used by copyright holders and the government to prevent the creation of third-party software products, silence computer scientists, and prosecute journalists who provide hypertext links to software code.</p>
}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What are technological protection measures?},
 answer:   %{.
<p>Technological protection systems are already in place in DVDs, eBooks, video game consoles, robotic toys, Internet streaming, and password-protected sections of web sites. The fact that a digital protection may be really weak and easy to circumvent has not prevented courts from applying this law to punish those who bypass them.</p>

<p>The DMCA defines an <b>access control</b> mechanism as a measure which "in the ordinary course of its operation, requires the application of information, or a process or a treatment, with the authority of the copyright owner, to gain access to the work." <a href="http://static.chillingeffects.org/1201.shtml#a_A">[1201(a)(3)(B)]</a> An access control is a technology, like a password or encryption that controls who or what is able to interact with the copyrighted work. It is a violation of the DMCA to circumvent access controls, but it is also a violation to provide tools to others that circumvent access controls (including selling, distributing free of charge, and possibly even linking to a site with such technology }
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Is there really a difference between access controls and copy controls?},
 answer:   %{<p>While there is a difference in the types of activities controlled by these technological protection measures, some copyright owners try to merge access and use controls in the implementation of these systems. For example, in trying to implement a "pay-per-use" business model, some copyright owners use a single persistent control system that charge separately for the different uses of a work even after paying to access a work.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What does circumvention mean?},
 answer:   %{<p>Circumvention, according to <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a_A">Section 1201(a)(3)(A)</a>, means "to descramble a scrambled work, to decrypt an encrypted work, or otherwise to avoid, bypass, remove, deactivate, or impair a technological measure, without the authority of the copyright owner."  While the full scope of activities and practices that would fall under this definition has not yet been examined by the courts, any act of undoing a "lock" or "block" in a digital system may well be considered circumvention.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a circumvention tool?},
 answer:   %{<p>The prohibited tools under the DMCA are the programs which are primarily designed or produced for the purpose of circumvention of an access <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a_A">[1201(2)(a)]</a> or copy control <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#b">[1201(b)(1)(A)]</a> mechanism. These programs can come in various forms including products, services, devices, or components. The DMCA includes in its definition of circumvention tools that these devices have limited commercially significant purposes other than circumvention or are marketed to be used for circumvention <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a_B">[1201(2)(B-C)]</a>, <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#b_B">1201(b)(1)(B-C)]</a>.</p>

<p>Congress intended the circumvention device bans to be analogous to laws that specifically prohibit the manufacture or distribution of descrambler boxes that allow access to cable television and satellite services without payment. However, the broad definition of circumvention tools in the DMCA creates numerous situations in which non-infringing uses of copyrighted works are prohibited as well merely because the technology necessary to engage in those legitimate uses is illegal under the circumvention device ban.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean to distribute circumvention tools?},
 answer:   %{<p><a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a2">Section 1201(a)(2)</a> defines distribution as the "manufacture, import, offer to the public, provide, or otherwise traffic" of circumvention tools. This definition can be interpreted extremely broadly as evident in the court's analysis in the DVD encryption <i>Universal v. Corley</i> case.  In its decision, the court considered not only making the source code of a program for free a type of distribution, but also found that merely linking to a web site containing illegal tools can constitute "trafficking."</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What kind of authorization is required of the copyright owner in order to legally circumvent a system?},
 answer:   %{It depends. In general, the anti-circumvention provisions of the DMCA reserve broad authority to copyright holders to determine who can circumvent their systems. 

For example, while the DMCA contains an encryption research exemption, to come under the exception,  a researcher must request the permission from the copyright holder to engage in circumvention in order to be exempted [1201(g)(2)(C)].  In addition, under the DMCA only individuals who are studying, trained, or employed in encryption research are likely to be considered legitimate researchers under the law [1201(g)(3)(B)].  Finally, an encryption researcher is required to immediately notify the creator of the protection system when she breaks it. [1201(g)(3)(C)]  The security testing exemption is even more restrictive in its rules about obtaining authorization from the copyright owner, requiring individuals engaged in security testing to not only request, but must actually obtain the authorization. [1201(j)(1)]  On the other hand, the exemption relating to law enforcement, intelligence, and other government purposes have no such requirements to notify copyright owners of their activities. [1201(e)]

One important limitation to the control given to copyright owners is that manufacturers and developers of consumers electronics, telecommunications, or computing products are not required to design their products to respond to the digital protection systems implemented by copyright owners in their works.  [1201(c)(3)] In this limitation, the DMCA anticipated the excessive control that copyright owners might exercise over the products used to play their works in addition to the works themselves.}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a system be legally circumvented?},
 answer:   %{<p>It depends. In general, the anti-circumvention provisions of the DMCA reserve broad authority to copyright holders to determine who can circumvent their systems.</p>

<p>For example, while the DMCA contains an encryption research exemption, to come under the exception,  a researcher must lawfully obtain the work and request the permission from the copyright holder to engage in circumvention in order to be exempted <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_2_C">[1201(g)(2)(C)]</a>. In addition, under the DMCA only individuals who are studying, trained, or employed in encryption research are likely to be considered legitimate researchers under the law <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_3_B">[1201(g)(3)(B)]</a>.  Finally, an encryption researcher is required to immediately notify the creator of the protection system when she breaks it. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_3_B">[1201(g)(3)(C)]</a>  The security testing exemption is even more restrictive in its rules about obtaining authorization from the copyright owner. It requires individuals engaged in security testing to not only request, but must actually obtain the authorization. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i_2_j">[1201(j)(1)] </a> On the other hand, the exemption relating to law enforcement, intelligence, and other government purposes have no such requirements to notify copyright owners of their activities. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#e">[1201(e)]</a></p>

<p>One important limitation to the control given to copyright owners is that manufacturers and developers of consumers electronics, telecommunications, or computing products are not required to design their products to respond to the digital protection systems implemented by copyright owners in their works.  <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#c_3">[1201(c)(3)]</a> In this limitation, the DMCA anticipated the excessive control that copyright owners might exercise over the products used to play their works in addition to the works themselves.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Are there exceptions in the DMCA to allow circumvention of technological protection systems?},
 answer:   %{<p>There are seven exemptions built into section 1201 of the DMCA, some of which permit the circumvention of access and copy controls for limited purposes, some of which allow for the limited distribution of circumvention tools in particular circumstances.  These seven exemptions are for:</p>

<blockquote><ul><li>Libraries, archives, and educational institutions for acquisition purposes; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#d">[1201(d)]</a>
<li> Law enforcement and intelligence gathering activities; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#e">[1201(e)]</a>
<li> Reverse engineering in order to develop interoperable programs; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#f">[1201(f)]</a>
<li> Encryption Research; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g">[1201(g)]</a>
<li> Protecting minors from material on the Internet; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#h">[1201(h)]</a>
<li> Protecting the privacy of personally identifying information; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i">[1201(i)]
<li> Security Testing <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i_1">[1201(j)]</a></ul></blockquote>

<p>In addition to these seven exemptions, the Library of Congress is required every three years to exempt the circumvention of measures that prevent the "fair use" of copyrighted works. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a_B">[1201(a)(1)(B-E)]</a>  The DMCA also contains provisions that ensure that the traditional rights of copyright law still apply to the DMCA.  <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#c">Section 1201(c)(1)</a> provides that the rights, remedies, limitations, or defenses to claims of copyright infringement still apply.  <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#c_4">Section 1201(c)(4)</a> states that these provisions should not affect the rights to free speech or freedom of the press for activities using electronics, telecommunications, or computing products.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How are libraries and archives affected by the anti-circumvention provisions?},
 answer:   %{<p>The DMCA provides an exemption for nonprofit libraries, archives, and educational institutions to circumvent a system protecting a copyrighted work in order to make a determination of whether or not to acquire the work. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#d">[1201(d)]</a> This exemption limits qualifying institutions from conducting circumvention only to those circumstances where accessing such a work is not made available in another medium. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#d_A_2">[1201(d)(2)]</a>  In addition, the exemption limits circumvention only for the limited time it takes the institution to make the decision whether or not to acquire the work. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#d_A">[1201(d)(1)(A)]</a></p>

<p>Libraries, educational institutions, and similar organizations are concerned that these technical protection systems and the laws supporting them give too much control to the copyright owner, and threaten the general public's ability to access these works.  The ban on the distribution of circumvention devices also means that libraries seeking to use this exemption can&#8217;t do so independently but must employ cryptographers to do so - a luxury most libraries can't afford.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Are law enforcement activities hindered by the anti-circumvention provisions?},
 answer:   %{<p>The DMCA permits law enforcement or intelligence agencies to circumvent technological protection systems in order to identify and address the vulnerabilities of government computer systems or networks.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a technological protection measure be reverse engineered?},
 answer:   %{<p><a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#f">Section 1201(f)</a> allows software developers to circumvent technological protection measures of a computer program that was lawfully obtained in order to identify the elements necessary to achieve the interoperability of an independently created computer program with other programs. A software developer may reverse engineer the program only if:
<ul><li>the elements necessary to achieve interoperability are not readily available and 
<li>reverse engineering is otherwise permitted under the copyright law.</ul></p>
<p>Software engineers are permitted to develop and employ circumvention devices for the purpose of achieving interoperability. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#f_2">[1201(f)(2)]</a>  Reverse engineers are exempt from the circumvention device ban only for the purpose of achieving interoperability, and not for gaining access to protected works for infringing purposes. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#f_2">[1201(f)(2)]</a></p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How do the DMCA's anti-circumvention provisions affect encryption researchers?},
 answer:   %{<p>The encryption research exemption is intended to protect circumvention that advances the state of knowledge in the field of encryption technology or assists in the development of encryption products. Circumvention in encryption research may be allowed if, when done in good faith, if the following conditions are met:
<ul><li>the researcher lawfully obtained the copyrighted work (ie. this exemption applies only to copy controls, not access controls); <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_2_A">[1201(g)(2)(A)]</a>
<li> circumvention is necessary for the encryption research; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_2_B">[1201(g)(2)(B)]</a>
<li> the researcher tried to obtain authorization from the copyright owner before the circumvention; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_2_C">[1201(g)(2)(C)]</a> and 
<li> circumvention is otherwise permissible under the applicable laws. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_2_C">[1201(g)(2)(D)]</a></ul>
 
<p>In addition to the above factors, the DMCA directs courts to consider three other factors in determining whether or not to apply the exemption in a particular case: 
<ul><li>whether the discovered information was disseminated, and if so, whether it was disseminated in a manner "reasonably calculated to advance" research or encryption technology development, or in a "manner that facilitates infringement";  <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_3_A">[1201(g)(3)(A)]</a>
<li> whether the researcher is engaged in a legitimate course of study, is employed, or is appropriately trained or experienced in the field of encryption technology; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_3_B">[1201(g)(3)(B)]</a> and 
<li> whether the researcher notifies the copyright owner in a timely fashion of the findings and documentation of the research. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#g_3_B">[1201(g)(3)(C)]</a></ul>

<p>Encryption researchers may develop, employ, and provide to collaborating researchers circumvention devices for the sole purpose of performing acts of good faith encryption research.</p>

<p>Leading cryptographers have criticized the exemption for covering too broad a range of activities and vaguely defining the permitted activities of researchers.  Most significantly, cryptographers fear that the publication of their research findings may be considered the distribution of circumvention devices.  Their vulnerability to being sued for the publication of their research is increased due to the requirement that they report their findings to the copyright owners, most likely before their findings can get published.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Digital Millennium Copyright Act?},
 answer:   %{The DMCA, as it is known, has a number of different parts.  One part is the anticircumvention provisions, which make it illegal to "circumvent" a technological measure protecting access to or copying of a copyrighted work (see <!--GET FAQLink 12-->).  Another part gives web hosts and Internet service providers a "safe harbor" from copyright infringement claims if they implement certain notice and takedown procedures (see <!--GET FAQLink 14-->).}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Is circumvention permitted in order to protect children from content on the Internet?},
 answer:   %{<p>The DMCA includes an exemption for both the circumvention and the circumvention device ban for programs whose sole purpose is to assist individuals to prevent minors from accessing objectionable material on the Internet. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#h">[1201(h)] </a> This exemption is unfortunately too narrow because the technological mechanisms protecting these materials may also be used to protect other types of materials on the Internet.  Developing and distributing a program that is designed for the protection of minors is vulnerable to legal liability for other uses that can be made of such a product.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Can you circumvent technological protection measures in order to protect your privacy?},
 answer:   %{<p>The exemption for the protection of personally identifying information permits the circumvention of a technological measure that collects personal information, such as the "cookie" feature on a browser.  However, the exemption is limited to circumstances in which:
<ul><li>there was not adequate notice to the user that the technological measure is used to collect or disseminate personally identifying information; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i_1_B">[1201(i)(1)(B)]</a>
<li> the circumvention has no other effect other than the ability to identify the collection or dissemination of information; <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i_1_c">[1201(i)(1)(C)]</a> and
<li> the act of circumvention is carried out solely for the purpose of identifying such information. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i_1_c">[1201(i)(1)(D)]</a></ul>

<p>The exemption allowing circumvention of personal information gathering technologies, though, is of limited use to the average consumer as a means to protect their privacy since the ban against circumvention devices does not exempt the distribution of privacy protection tools.  Individuals must therefore have the expertise to analyze and manipulate computer source code in order to protect their privacy on the Internet if digital protection systems are used in information gathering technologies.</p>
}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How do the anti-circumvention provisions affect security testing?},
 answer:   %{<p>The DMCA permits circumvention that is conducted in the course of testing security systems if it is otherwise legal under the law. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i_2_j">[1201(j)]</a> Security testing is defined in the DMCA as "obtaining access, with proper authorization, to a computer, computer system, or computer network for the sole purpose of testing, investigating or correcting a potential or actual security flaw, or vulnerability or processing problem." <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#i_2_j">[1201(j)(1)]</a> In determining whether this exception is applicable, the DMCA requires the court to consider whether the information derived from the security testing was used solely to improve the security measures or whether it was used to facilitate infringement. The DMCA also permits the development, production or distribution of technological means for the sole purpose of circumvention devices for the sole purpose of performing permitted acts of security testing.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{Do the anti-circumvention provisions affect analog devices?},
 answer:   %{<p>The DMCA requires analog video cassette recorders to conform to the two forms of copy control technology that are in wide use in the market today - the automatic gain control technology and the colorstripe copy control technology. In addition, the DMCA prohibits the redesigning of video recorders or the use of "black box" devices or "software hacks" to circumvent these copy controls.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How is the development of interoperable products affected by the DMCA?},
 answer:   %{<p>The anti-circumvention provisions may hinder innovation in information technology by limiting the ability of potential competitors to reverse engineer the technological protection system behind which the original manufacturer hides their product. Reverse engineering is a traditional method used by industry to understand how systems work and create interoperable products.  While the DMCA has an exception that permits reverse engineering to create interoperable products, as discussed below, it may only permit reverse engineering for interoperability between programs, but not for the purpose of making a program available in other platforms. .  A strict interpretation of the DMCA may prohibit reverse engineering, regardless of whether or not copyright infringement occurs in the process.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How is the general public affected by the DMCA?},
 answer:   %{<p>Conspicuously missing from the exemptions provided for circumvention activities is the average consumer's right to use and explore the products and services they purchase. The only provisions aimed at consumers directly, exempt the circumvention of: a) technologies that collect personal information (the privacy exemption); and, b) technologies used to protect minors from access to certain web sites.  These exemptions, like the others, are extremely narrow.  For example, the privacy exemption only allows circumvention to defeat the data collection activity of the technical protection measure.  If by defeating the data collection element you defeat other aspects of the technical protection measure you}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Copyright Office Rulemaking exemption in the DMCA?},
 answer:   %{<p>The act of circumvention provision calls for a review of the prohibition on circumventing access controls every three years. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a_B">[1201(a)(1)(B)]</a> The rulemaking proceedings conducted by the Copyright Office are  supposed to document whether noninfringing uses of particular kinds of copyrighted works are hampered by the prohibition. After the Copyright Office makes its recommendations, the Library of Congress can create "classes of works" that users may access through circumvention without obtaining authorization from the copyright owner. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a_B">[1201(a)(1)(B)]</a></p>

<p>This amendment is intended to transform the prohibition of circumvention into a form of regulation that monitors developments in the marketplace for circumstances in which certain copyrighted materials become less available to the general public. This regulation system may be ineffective if the Copyright Office's findings also affect the circumvention device ban because of the necessity of using some sort of tool in order to engage in the exempted acts.<p>

<p>The Copyright Office issued the following classes of works as exemptions to the circumvention activity ban at the conclusion of its first rulemaking proceedings: 
<ol><li>Compilations consisting of lists to websites blocked by filtering software applications; and
<li>Literary works, including computer programs and databases, protected by access control mechanisms that fail to permit access because of malfunction, damage, or obsoleteness.
<a href="http://www.loc.gov/copyright/fedreg/65fr64555.html">[Exemption to Prohibition on Circumvention of Copyright Protection Systems for Access Control Technologies, 37 C.F.R. }
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a class of works in the DMCA's Copyright Office Rulemaking?},
 answer:   %{<p>The Copyright Office interpreted a class of works as a subset of the broad categories of works of authorship of copyright law. The categories of authorship referred to include: literary works; musical works; dramatic works; pantomimes and choreographic works; pictorial, graphic, and sculptural works; motion pictures and other audiovisual works; sound recordings; and architectural works.  The useful implementation of the Copyright Office's findings based on such categorization does not necessarily correspond to the the digital protection mechanisms developed by the entertainment, electronics, and computer industries.  The encryption systems developed may be implemented in the protection of various kinds of works in different types of media.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the basis for exempting "classes of works" from the DMCA?},
 answer:   %{<p>The determination of exempted works must be based on a finding of the "adverse effects" digital protection systems have on users.  The criteria that the Copyright Office is directed to consider in evaluating these effects are:
<ol><li type="i">the availability for use of copyrighted works;
<li type="i">the availability for use of works for nonprofit archival, preservation, and educational purposes;
<li type="i">the impact that the prohibition on the technological measures applied to copyrighted works on criticism, comment, news reporting, teaching, scholarship, or research;
<li type="i">the effect of circumvention of technological measures on the market for or value of copyrighted works; and
<li type="i">such other factors as the Librarian considers appropriate. [1201(a)(1)(C)]</ol>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the DMCA's software filtering exemption?},
 answer:   %{<p>Lists of web sites filtered by software programs, generally designed to restrict Internet users from visiting certain web sites and protect children from inappropriate material, were exempted. The Copyright Office found that  the criticism and commentary on the efficacy of such software is impossible without the ability to circumvent those programs. Many of these "blocked sites" are identified in encrypted lists within the software. In order for a party to learn if their site is one of the "blocked sites" it is necessary for these lists to be accessed and searched. The Copyright Office noted that there was no other legitimate way to obtain access to this information other than in digital form.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the DMCA's malfunction exemption?},
 answer:   %{<p>Due to the incidences of software and electronics products manufacturers that go bankrupt or do not respond to customer service complaints, it is not a violation of the DMCA to circumvent malfunctioning, damaged or obsolete software programs that use access control mechanisms. The Copyright Office noted that such circumvention is reserved for only those circumstances where an individual sought, but failed to receive assistance from the copyright owner.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the effect of the anti-circumvention provisions on the traditional defenses to copyright law?},
 answer:   %{<p><a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#c">Section 1201(c)(1)</a> explicitly provides that: "Nothing in this section shall affect rights, remedies, limitations, or defenses to copyright infringement, including fair use." Substantial question remains over whether or not courts will interpret the traditional defenses to copyright infringement as defenses to the anti-circumvention provisions as well. Recent court decisions have not found the fair use defense to apply to violations of the anti-circumvention provisions of the DMCA. By making the circumvention prohibitions distinct from copyright infringement, defendants can be held liable for circumventing an access control measure even if the uses made of the work are held not to infringe on the rights of the copyright owner. Disengaging the anti-circumvention provisions from the traditional fair use analysis effectively limits use of copyrighted materials to solely what is explicitly permitted by the copyright owner. The concept of fair use remains, but for all practical purposes only those uses sanctioned by the copyright owner are permissible. The anti-circumvention provisions of the DMCA essentially replaces the broad contextual defense of fair use, discussed below, with a narrow set of carve outs to an otherwise absolute right of the copyright owners to control access and use of their works.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What is fair use?},
 answer:   %{<p>Copyright law seeks to promote the production and distribution of creative works by conferring property rights on authors. The principle of fair use serves to mediate between these property rights and the constitutional rights of public access and free speech embodied in the First Amendment.  Fair use serves an important social function by allowing for the use of parts of creative works for the sake of criticism, commentary, and reporting.</p>

<p>To decide whether a use is "fair use" or not, courts consider:
<ol><li>the purpose and character of the use, including whether such use is of a commercial nature or is for nonprofit education purposes;
<li>the nature of the copyrighted work; 
<li>the amount and substantiality of the portion used in relation to the copyrighted work as a whole; and,
<li>the effect of the use upon the potential market for or value of the copyrighted work.<a href="http://www4.law.cornell.edu/uscode/17/107.html">[17 U.S.C. 107(1-4)]</a></ol></p>

<p>The principles of fair use are invoked when the transaction costs associated with gaining authorization from copyright owners to make use of works is too burdensome in reasonable circumstances. Fair use also permits the reproduction of art and information for the private, noncommercial sharing of those works. Fair use allows for market competitors to use copyrighted works in ways that allow them to extract the public domain aspects of those works in order to develop innovative products.</p>
}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How does the DMCA affect the public domain?},
 answer:   %{<p>As more information migrates toward digital storage and distribution, the ability to quote, criticize, and make other "fair uses" of a large amount of our cultural artifacts may be practicably lost.</p>

<p>Collections of works that contain only a limited amount of copyrightable subject matter, made up mostly of facts, or that contain other significant public domain materials, are vulnerable to being locked up by copyright owners behind technological protection systems. The protection of these "thin copyrights" behind access control mechanisms gives copyright owners control over works that are not intended to be protected by copyright law.</p>
}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How does the DMCA affect the first sale doctrine?},
 answer:   %{<p>First Sale is an important protection for the public in copyright law. The first sale doctrine permits individuals who buy products containing copyrighted information to choose whether to sell, share, rent or simply give them away. As more information migrates toward digital storage and distribution, copyright owners prefer licensing, rather than selling, copyrighted material. These licensed products often contain technical protection measures that control access and copying.  The concern is that the trends toward digital distribution, licensing, and technical locks, coupled with the prohibitions of the DMCA will undermine the protections for the public found in the first sale doctrine.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{How is the First Amendment affected by the DMCA?},
 answer:   %{<p>The tension between the DMCA and the First Amendment is at the heart of several ongoing lawsuits. [Felten v. RIAA; Universal v. Corley] The mere posting of a link to a computer program that can be used to circumvent technical protection measures was held to be a violation of the DMCA. [Universal v. Corley (2d Ciruit cite)] The Recording Industry Association of America used the threat of a DMCA action to silence a professor whose research paper discussed circumvention of a technical protection measure. The professor subsequently mounted a legal challenge to the DMCA on First Amendment grounds and presented his paper. While courts in both of these cases have found in favor of the copyright industries, these cases are being appealed and the state of the law is yet to be determined.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the penalties for violating the DMCA's anti-circumvention provisions?},
 answer:   %{<p>The DMCA allows for both civil remedies and criminal penalties for violations under the anti-circumvention provisions. If the violations are determined to be willful and for commercial purposes or private financial gain, the court can order significant fines and/or imprisonment.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the civil penalties for a DMCA 1201 violation?},
 answer:   %{<p>Civil cases are brought in federal district court where the court has broad authority to grant injunctive and monetary relief. Injunctions can be granted forbidding the distribution of the tools or products involved in the violation. The court may also order the destruction of the tools or products involved in the violation. The court can also award actual damages, profits gained through infringement, and attorney's fees. If an individual held in violation of the DMCA commits another such violation within the three-year period following the judgment, the court may increase the damages up to triple the amount that would otherwise be awarded.</p>

<p>In circumstances involving innocent violators, it is up to the courts to decide whether to reduce damages. But, in the case of nonprofit library, archives or educational institutions, the court must remit damages if it finds that the institution did not know of the violation.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the criminal penalties for a DMCA 1201 violation?},
 answer:   %{<p>If the circumvention violations are determined to be willful and for commercial or private financial gain, first time offenders may be fined up to $500,000, imprisoned for five years, or both. For repeat offenders, the maximum penalty increases to a fine of $1,000,000, imprisonment for up to ten years, or both. Criminal penalties are not applicable to nonprofit libraries, archives, and educational institutions.</p>}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the DMCA Safe Harbor Provisions?},
 answer:   %{<p>In 1998, Congress passed the On-Line Copyright Infringement Liability Limitation Act (OCILLA) in an effort to protect service providers on the Internet from liability for the activities of its users.  Codified as <a href="http://www4.law.cornell.edu/uscode/17/512.html">section 512 of the Digital Millennium Copyright Act (DMCA)</a>, this new law exempts on-line service providers that meet the criteria set forth in the safe harbor provisions from claims of copyright infringement made against them that result from the conduct of their customers.  These safe harbor provisions are designed to shelter service providers from the infringing activities of their customers.  If a service provider qualifies for the safe harbor exemption, only the individual infringing customer are liable for monetary damages; the service provider's network through which they engaged in the alleged activities is not liable.</p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trademark tarnishment?},
 answer:   %{Trademark "tarnishment," a kind of dilution, can occur if a non-owner uses the mark in connection with shoddy or unsavory products or services, illegal activity, or activity that is likely to offend the average person.  For example, using a Walt Disney trademark on a website filled with pornography could be claimed to tarnish the reputation of the Disney mark in the minds of viewers who saw this material.  Tarnishment is not always actionable -- it might be non-commercial or parody use.
 }
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What defines a service provider under section 512 of the Digital Millennium Copyright Act (DMCA)?},
 answer:   %{<p>A service provider is defined as "an entity offering transmission, routing, or providing connections for digital online communications, between or among points specified by a user, of material of the user's choosing, without modification to the content of the material as sent or received" or "a provider of online services or network access, or the operator of facilities thereof." [512(k)(1)(A-B)]   This broad definition includes network services companies such as internet service providers (ISPs), search engines, bulletin board system operators, and even auction web sites.  In <i>A&M Records, Inc. v. Napster Inc.</i>, the court refused to extend the safe harbor provisions to the Napster software program and service, leaving open the question of whether peer-to-peer networks also qualify under section 512.

There are four major categories of network systems offered by service providers that qualify for protection under the safe harbor provisions:
<sum> Conduit Communications include the transmission and routing of information, such as an email or internet service provider, which store the material only temporarily on their networks. [Sec. 512(a)] 
<sum> System Caching refers to the temporary copies of data that are made by service providers in providing the various services that require such copying in order to transfer data. [Sec. 512(b)] 
<sum> Storage Systems refers to services which allow users to store information on their networks, such as a web hosting service or a chat room. [Sec. 512(c)] 
<sum> Information Location Tools refer to services such as search engines, directories, or pages of recommended web sites which provides links to the allegedly infringing material. [Sec. 512(d)]
}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What defines a service provider under Section 512 of the Digital Millennium Copyright Act (DMCA)?},
 answer:   %{<p>A service provider is defined as "an entity offering transmission, routing, or providing connections for digital online communications, between or among points specified by a user, of material of the user's choosing, without modification to the content of the material as sent or received" or "a provider of online services or network access, or the operator of facilities thereof." [512(k)(1)(A-B)]   This broad definition includes network services companies such as Internet service providers (ISPs), search engines, bulletin board system operators, and even auction web sites.  In <i>A&M Records, Inc. v. Napster Inc.</i>, the court refused to extend the safe harbor provisions to the Napster software program and service, leaving open the question of whether peer-to-peer networks also qualify for safe harbor protection under Section 512.</p>

<p>There are four major categories of network systems offered by service providers that qualify for protection under the safe harbor provisions:
<ul><li>Conduit Communications include the transmission and routing of information, such as an email or Internet service provider, which store the material only temporarily on their networks. [Sec. 512(a)] 
<li>System Caching refers to the temporary copies of data that are made by service providers in providing the various services that require such copying in order to transfer data. [Sec. 512(b)] 
<li>Storage Systems refers to services which allow users to store information on their networks, such as a web hosting service or a chat room. [Sec. 512(c)] 
<li>Information Location Tools refer to services such as search engines, directories, or pages of recommended web sites which provide links to the allegedly infringing material. [Sec. 512(d)]</ul>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a service provider have to notify its users about its policies regarding the removal of materials?},
 answer:   %{<p>To qualify for exemption under the safe harbor provisions, the service provider must give notice to its users of its policies regarding copyright infringement and the consequences of repeated infringing activity.  [512(i)(1)(A)]  The notice can be a part of the contract signed by the user when signing up for the service or a page on the service provider's web site explaining the terms of use of their systems.  While there are no specific rules about how this notice must be made, it must be "reasonably implemented" so that subscribers and account holders are informed of the terms. [512(i)(1)(A)]</p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What does a service provider have to do in order to qualify for safe harbor protection?},
 answer:   %{<p>In addition to informing its customers of its policies <a href="#QID128">(discussed above)</a>, a service provider must follow the proper notice and takedown procedures <a href="#QID130">(discussed above)</a> and also meet several other requirements in order to qualify for exemption under the safe harbor provisions.</p> 

<p>In order to facilitate the notification process in cases of infringement, ISPs which allow users to store information on their networks, such as a web hosting service, must designate an agent that will receive the notices from copyright owners that its network contains material which infringes their intellectual property rights.  The service provider must then notify the Copyright Office of the agent's name and address and make that information publicly available on its web site. [512(c)(2)]</p>

<p>Finally, the service provider must not have knowledge that the material or activity is infringing or of the fact that the infringing material exists on its network.  [512(c)(1)(A)], [512(d)(1)(A)]. If it does discover such material before being contacted by the copyright owners, it is instructed to remove, or disable access to, the material itself.  [512(c)(1)(A)(iii)], [512(d)(1)(C)]. The service provider must not gain any financial benefit that is attributable to the infringing material. [512(c)(1)(B)], [512(d)(2)].</p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the notice and takedown procedures for web sites?},
 answer:   %{<p>In order to have an allegedly infringing web site removed from a service provider's network, or to have access to an allegedly infringing website disabled, the copyright owner must provide notice to the service provider with the following information:
<ul class="main"><li>The name, address, and electronic signature of the complaining party [512(c)(3)(A)(i)]
<li>The infringing materials and their Internet location [512(c)(3)(A)(ii-iii)], or if the service provider is an "information location tool" such as a search engine, the reference or link to the infringing materials [512(d)(3)].
<li>Sufficient information to identify the copyrighted works [512(c)(3)(A)(iv)].
<li>A statement by the owner that it has a good faith belief that there is no legal basis for the use of the materials complained of [512(c)(3)(A)(v)].
<li>A statement of the accuracy of the notice and, under penalty of perjury, that the complaining party is authorized to act on the behalf of the owner [512(c)(3)(A)(vi)].</ul></p>

<p>Once notice is given to the service provider, or in circumstances where the service provider discovers the infringing material itself, it is required to expeditiously remove, or disable access to, the material.  The safe harbor provisions do not require the service provider to notify the individual responsible for the allegedly infringing material before it has been removed, but they do require notification after the material is removed.</p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a copyright owner have to specify the exact materials it alleges are infringing?},
 answer:   %{<p>Proper notice under the safe harbor provisions requires the copyright owners to specifically identify the alleged infringing materials, or if the service provider is an "information location tool" such as a search engine, to specifically identify the links to the alleged infringing materials.  [512(c)(3)(iii)], [512(d)(3)].  The provisions also require the copyright owners to identify the copyrighted work, or a representative list of the copyrighted works, that is claimed to be infringed.  [512(c)(3)(A)(ii)].  Rather than simply sending a letter to the service provider that claims that infringing material exists on their system, these qualifications ensure that service providers are given a reasonable amount of information to locate the infringing materials and to effectively police their networks. [512(c)(3)(A)(iii)], [512(d)(3)].</p>

<p>However, in the recent case of <i>ALS Scan, Inc. v. Remarq Communities, Inc.</i>, the court found that the copyright owner did not have to point out all of the infringing material, but only substantially all of the material. The relaxation of this specificity requirement shifts the burden of identifying the material to the service provider, raising the question of the extent to which a service provider must search through its system. OSP customers should note that this situation might encourage OSP's to err on the side of removing allegedly infringing material.</p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the counter-notice and put-back procedures?},
 answer:   %{<p>In order to ensure that copyright owners do not wrongly insist on the removal of materials that actually do not on infringe their copyrights, the safe harbor provisions require service providers to notify the subscribers if their materials have been removed and to provide them with an opportunity to send a written notice to the service provider stating that the material has been wrongly removed.  [512(g)] If a subscriber provides a proper "counter-notice" claiming that the material does not infringe copyrights, the service provider must then promptly notify the claiming party of the individual's objection.  [512(g)(2)] If the copyright owner does not bring a lawsuit in district court within 14 days, the service provider is then required to restore the material to its location on its network. [512(g)(2)(C)]</p>

<p>A proper counter-notice must contain the following information:
<ul class="main"><li>The subscriber's name, address, phone number and physical or electronic signature [512(g)(3)(A)]
<li>Identification of the material and its location before removal [512(g)(3)(B)]
<li>A statement under penalty of perjury that the material was removed by mistake or misidentification [512(g)(3)(C)]
<li>Subscriber consent to local federal court jurisdiction, or if overseas, to an appropriate judicial body. [512(g)(3)(D)]</ul></p>

<p>If it is determined that the copyright holder misrepresented its claim regarding the infringing material, the copyright holder then becomes liable to the OSP for any damages that resulted from the improper removal of the material. [512(f)]</p>}
)

mapping[%{DMCA Notices}] << q.id

q = RelevantQuestion.create!(
 question: %{What happens if an individual is found to repeatedly infringe?},
 answer:   %{<p>The safe harbor provisions require the service provider to include in its copyright infringement policies a termination policy that results in individuals who repeatedly infringe copyrighted material being removed from the service provider networks. [512(i)(1)(A)]  This termination policy must be made public in the terms of use that the service provider includes in its contracts or on its web site.</p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a copyright owner find out the identity of the individual responsible for the allegedly infringing material?},
 answer:   %{The safe harbor provisions permit a copyright owner to subpoena the identity of the individual allegedly responsible for the infringing activities.  [512(h)]  Such a subpoena is granted on the condition that the information about the individual's identity will only be used in relation to the protection of the intellectual property rights of the copyright owner. [512(h)(2)(C)]

The DMCA subpoena provision does not apply to requests for the identities of users of ISP conduit 512(a) services, but only to users of hosting or linking, for which a takedown may be sent under 512(c)(3)(A).  Thus DMCA subpoenas cannot be used to find the identities of users engaged in peer-to-peer filesharing. Recording Industry Assoc. of America v. Verizon Internet Svcs., Inc.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{How are the safe harbor provisions applied to educational institutions?},
 answer:   %{<p>The safe harbor provisions make a special exception to educational institutions that qualify as service providers under section 512.  [512(e)]  While a corporation is responsible for the activities of its employees, faculty members or graduate student employees who are performing teaching or research functions are not considered a part of the institution itself for certain infringing activities so as to maintain the academic freedom of these institutions. [512(e)(1)]</p>  

<p>The institution can therefore avoid liability for infringement even if the infringing individuals knew they were infringing, provided that:
<ul><li>the infringing activities did not involve the provision of access to materials required for a course within the previous three years [512(e)(1)(A)]
<li>the institution has not received more than two notifications of alleged infringement by the faculty member or graduate student in the preceding three year period [512(e)(1)(B)]
<li>the institution provides all users of its network or system with informational materials that describe and promote compliance with copyright law [512(e)(1)(C)]</ul></p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{If a hyperlink is just a location pointer, how can it be illegal?},
 answer:   %{. 
It probably isn't, however, a few courts have now held that a hyperlink violates the law if it points to illegal material with the <i>purpose of disseminating that illegal material</i>:  <ul>
<li>In the DeCSS case, <a href="http://eon.law.harvard.edu/openlaw/DVD/NY/">Universal v. Reimerdes</a>, the court barred 2600 Magazine from posting hyperlinks to DeCSS code because it found the magazine had linked for the purpose of disseminating a circumvention device. (See <!--GET CatLink 12-->.) The court ruled that it could regulate the link because of its "function," even if the link was also speech.  
<li> In another case, <a href="http://www.law.uh.edu/faculty/cjoyce/copyright/release10/IntRes.html">Intellectual Reserve v. Utah Lighthouse Ministry</a>, a Utah court found that linking to unauthorized copies of a text might be a contributory infringement of the work's copyright. (The defendant in that case had previously posted unauthorized copies on its own site, then replaced the copies with hyperlinks to other sites.)
</ul>
By contrast, the court in <a href="http://www.gigalaw.com/library/ticketmaster-tickets-2000-03-27.html">Ticketmaster v. Tickets.com</a> found that links were not infringements of copyright.
</p><p>
Like anything else on a website, a hyperlink could also be problematic if it <i>misrepresents</i> something about the website.  For example, if the link and surrounding text falsely stated that a website is affiliated with another site or sponsored by the linked company, it might be false advertising or defamation.  
</p>
<p>Finally, post-<a href="http://www.eff.org/IP/P2P/MGM_v_Grokster/">Grokster</a>, a hyperlink might be argued to induce copyright infringement, if the link were made knowing that the linked-to material was infringing and with the intent of inducing people to follow the link and infringe copyright.</p>
<p>In most cases, however, simple linking is unlikely to violate the law.</p>}
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{What kinds of things are copyrighted? 

},
 answer:   %{In order for a work to be protected by copyright, it must be an original creation set in a fixed medium.

An artist or author does not have a copyright in material borrowed from someone else.  Also, stock characters (the sidekick) or plot lines (boy meets girl) are not copyrightable. 

The requirement that works be in a fixed medium means certain forms of expression, most notably choreography and oral performances such as speeches, are not copyrighted, (unless they are being recorded contemporaneously). For instance, if I perform a Klingon death wail in a local park, my wail of death is not copyrighted, and someone else may come along and do the same thing the next day.  However, if I film the performance, then the Klingon death wail does become copyrighted (since it is now "fixed" according to copyright law).  Contrary to popular belief, I do not have to register my copyrighted work for it to receive copyright protection.  In the United States, I only need to register if I'm going to sue.  

}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What is fair use and how does it relate to Fan Fiction?

},
 answer:   %{The fair use doctrine says that otherwise copyrighted works may be used for purposes such as criticism, comment, news reporting, teaching, scholarship, or research.  To decide whether a use is "fair use" or not, courts consider:

(1) the purpose and character of the use, including whether such use is of a commercial nature or is for nonprofit educational purposes;
(2) the nature of the copyrighted work;
(3) the amount and substantiality of the portion used in relation to the copyrighted work as a whole; and
(4) the effect of the use upon the potential market for or value of the copyrighted work.

Parody is also fair use.  

Under this doctrine, artists have been permitted to create and display their art even if it uses copyrighted works of others.  See <a href=&quot;http://abcnews.go.com/sections/us/DailyNews/barbie010223.html&quot;>Court Allows Artist to Sell Barbie Art</a>, for an example.

There is a strong argument that many fan fiction stories are transformative since they create a different persona and set of events for the character. To create a new story cannot be seen as the same as posting video clips on a website. There must be a balancing between protecting copyrights in order to encourage innovation by authors and between allowing works to be in the public domain to allow creative uses. 

Whether a court will view this as the case for a particular work of fan fiction depends on how much of the story relies on copyrighted materials, whether the story is sold, or affects the market for the copyrighted work, and other factors.  There is no easy answer to the question, which is why it is often a good idea to consult a lawyer who can assess the particular facts of your case.  
}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Is FanFic an illegal act of copying?},
 answer:   %{If a Fan Fiction author uses copyrighted elements in someone else's work in his/her story, then the fan fiction may be a derivative work.  There are many elements of a work that an author can borrow. The law, however, does not clearly define whether fictitious characters, worlds, histories and names are copyright protected.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Aren't I allowed to make a backup copy of my software?
 
},
 answer:   %{Yes, but only for specifically authorized archival purposes, as specified in 17 U.S.C. sec. 117(2).  This does not authorize sharing or selling of backup copies.  The rule allows transfer to another person only with the explicit authorization of the copyright owner and only if he original copy is transferred.  Backups for individual use and those considered "an essential step" in using the software with an individual's computer are also authorized. }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Is all copying piracy?
},
 answer:   %{No. Copyright gives the owner exclusive rights to reproduce, adapt, publicly distribute, perform and display their work.  Nonetheless, the law allows "fair use" of copyrighted material. Fair use permits, in certain circumstances, the use or copying of all or a portion of a copyrighted work without the permission of the owner. Copyrighted works may be used for purposes such as criticism, comment, news reporting, teaching, scholarship, or research. To decide whether a use is "fair use" or not, courts consider, in part:
(1) the purpose and character of the use  (including whether such use is of a commercial nature or is for nonprofit educational purposes);
(2) the nature of the copyrighted work (giving creative works more protection than factual works);  
(3) the amount and substantiality of the portion used in relation to the copyrighted work as a whole (including size and quality- i.e. Does the portion represent the "heart" of the work); and
(4) the effect of the use upon the potential market for or value of the copyrighted work. 

Courts balance these factors, placing an emphasis on the fourth, however rulings have been unpredictable.  Parody may be protected by fair use where the user is actually making a comment on or criticism of the copyrighted material, even if a profit is made from the use.  Still, distributing copyrighted software will rarely be fair use because people will use those copies instead of buying the software from the legitimate vendor.  
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the purpose of copyright law?},
 answer:   %{Copyright law provides an incentive to create software, music, literature and other works by ensuring that the creator will be able to reap the financial benefits of the work.}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{If I am accused of "piracy," what does this mean?},
 answer:   %{"Piracy" is slang for copyright infringment, usually used to describe the unlawful copying of software, videogames, movies or MP3s. Copyright law gives a creator of software, music, literature and other works a limited monopoly to reproduce or distribute in the created work. If you are accused of piracy, then someone is claiming that you have violated their copyright by copying part or all of their work without authorization, or have enabled other people to make such copies.  }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{My website contains a disclaimer that clearly states that I do not support or promote copyright infringment.  Will this protect me?},
 answer:   %{Adding such a disclaimer on your web site will not necessarily protect you from a lawsuit or criminal liability if in fact copyrighted works are being illegally copied and distributed.  For more information, you should see the Safe Harbor provisions of this website.}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Why is "piracy" such a big issue now?  },
 answer:   %{Digital technology allows perfect copies and easy distribution of some works.  That makes it easier for people to make and get copies of songs or videogames, and more difficult for copyright holders (record companies, etc.) to control the works once they are released to the public.  This new technology has changed the way content distributors relate with their customers, and law and business models are just trying to catch up.  }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Do I have trademark rights in my domain name? 

},
 answer:   %{You may actually have trademark rights superior to those of your accuser. You may have such trademark rights because 
(a) you have a registered trademark;  
(b) you have a pending "intent to use" trademark application, of which the filing date predates the use of the mark by your accuser; 
(c) you have a pending "use based" trademark application and your date of first use predates the first use of the mark by your accuser; or 
(d) you have ?common law? rights to the trademark.  

 In the U.S., the person who establishes priority in a mark gains the ultimate right to use it.  According to the Lanham Act, determining who owns a mark involves establishing who first used it to identify his/her goods.  That means, in the United States, you do not need to register a mark to establish rights to it. However, registering a mark means that the registrant is presumed to be the owner of the mark for the goods and services specified in the application. 
}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{Aren},
 answer:   %{Not with the initial request. The reasons for the subpena are only provided if the subpena is challenged, through a motion to quash.  In opposing the motion to quash, the person seeking the information must demonstrate, at a minimum, that it is likely to lead to the discovery of information that would be useful in a lawsuit.  }
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{I signed a confidentiality/privacy agreement with my ISP that provides that they will not release my information.  Doesn},
 answer:   %{No. Most privacy agreements state that information will be turned over in response to legal requests, and a subpena is such a request.  Even if the agreement does not say so, a legally issued subpoena overrides such agreements as a matter of public policy.  Each ISP has a different policy about notifying users when their information has been subpoenaed, but they cannot simply ignore a subpoena under the law without risking legal santion themselves. 
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{I don},
 answer:   %{Any information that your ISP has may be subject to a subpoena, including information you may keep in calendars, preferences, "myXXX" systems hosted by your ISP, as well as log files. Different ISPs keep different kinds of records of customer behavior.  Ask your ISP to be certain that you know what information they maintain about you.}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{How do I prove that I have trademark rights in my domain name?
},
 answer:   %{    Under (a), (b), and (c) above, if you have registered the trademark or have filed an application for the trademark that predates your accuser's use, your priority will be easy to prove. 

    Under (d), above, to prove that you have "common law" rights in the trademark, you will need to prove when you first started to use the trademark. The following evidence can help you establish this:

 1. Advertising predating your accuser's use of the mark.
      i.  Copies of advertisements showing your use of the
      ii. Public relation materials showing your use of the
      iii.Search on Internet for review of articles mentioning your use of the mark for your product or services
      iv. Advertising bills specifically mentioning ads for the product or services.
 
    2. Any receipts or other documents showing sales of the product

    3. Any articles that contain a review of your product or services.
    
    4. Any listing in trade brochures indicating use of the mark at a trade show.

    5.Any other documents which show when you started making the product or offering the services.

   All of these will need to be dated, or you will need some way of proving that they pre-date your accusers use of the mark.
}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What information is available to someone researching domain name ownership?},
 answer:   %{A "Whois" record. A "Whois" record is the information provided to a registrar when someone registers a domain name.  This record generally includes the name and contact information of the "owner" of the domain name, as well as the technical contact and the billing contact.  Often, these contacts are the same person.  (The IP address for the web site is also included in a Whois record. This provides the address of where the site is hosted.)}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a subpoena (also spelled "subpena")?},
 answer:   %{A subpoena is a formal demand that a person or company produce evidence in or for a civil or criminal lawsuit.  A subpoena duces tecum (the kind most commonly used in John Doe cases) requires only the production of identified documents or categories of documents.  }
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What does "respond" to the subpena mean?},
 answer:   %{Usually, it means that the ISP will give the requested information to the requesting person.  In some cases, ISPs have resisted requests for information on behalf of their customers, but this is not the norm.  Unless specifically told differently by your ISP, you should assume that your ISP will turn over your information as part of its response.}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "motion to quash" a subpoena?},
 answer:   %{This is a formal request for a court to rule that your information should not be given to the requesting party.  This normally includes the request, plus a legal brief (sometimes called a memorandum of points and authorities) explaining why, by law, your information should not be turned over.  Samples of briefs filed in John Doe cases are available at:

<a href="http://www.eff.org/Privacy/Anonymity/Cullens_v_Doe/">EFF Archive, Cullens v. Doe, http://www.eff.org/Privacy/Anonymity/Cullens_v_Doe/</a>
<a href="http://www.citizen.org/litigation/briefs/IntFreeSpch/articles.cfm?ID=5801">http://www.citizen.org/litigation/briefs/IntFreeSpch/articles.cfm?ID=5801</a>
}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What if I need to contact an attorney?},
 answer:   %{This website is meant as an aid to help you decipher Cease and Desist notices so you can make informed decisions about your course of action. If, after reading this, you think the C&D you received might have some merit, or you think you might engage your opponent in battle even if the C&D is, in your opinion, baseless, consultation with an attorney is always a good idea.  

The <a href="http://www.omln.org/">Online Media Legal Network (OMLN)</a> is a network of law firms, law school clinics, in-house counsel, and individual lawyers throughout the United States willing to provide pro bono (free) and reduced fee legal assistance to qualifying online journalism ventures and other digital media creators. 

You can find an intellectual property attorney at <a href="http://www.martindale.com">www.martindale.com</a> or by calling your state or local <a href="http://www.romingerlegal.com/natbar.htm">Bar Association</a> and asking for a referral.       }
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{How do I find a "WHOIS" record?},
 answer:   %{On the web, you can start with the InterNIC registrar lookup, <a href="http://www.internic.net/whois.html">http://www.internic.net/whois.html</a> and follow that to the registrar's website, or try combined lookups at <a href="http://www.samspade.org/#TOC1">SamSpade</a>, <a href="http://www.geektools.com/whois.php">GeekTools</a>, or <a href="http://www.uwhois.com/cgi/domains.cgi?User=Default">uWhois</a>. Command line tools are available that use the port 43 WHOIS protocol. 
}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What does a "Whois" record say about domain name ownership?},
 answer:   %{The Whois record lists the name of the person or entity who is listed as the owner of record of the domain name.  The information supplied, however, may not be strictly accurate.}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What does a "Whois" record omit to say about domain name ownership?},
 answer:   %{A Whois record does no include any information with regard to chain of title.  It merely lists the current owner of record.  This means that you cannot determine who the original owner of a domain name was if the domain name had been transferred.}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{How reliable is a "Whois" record?},
 answer:   %{The information in a Whois record is only as reliable as the person providing the information.  While the information is supposed to be accurate and updated, this is often not the case.  However, even the inaccurate Whois information may, in certain circumstances, be grounds for suspension of a given domain name.}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a hyperlink?},
 answer:   %{Unless you typed the <a href="http://webopedia.com/TERM/U/URL.html">URL</a> directly into your web browser, you probably followed a hyperlink to get to this page.  A hyperlink is a location reference that the web browser interprets, often by underlining the text in blue, to "link" to another information resource when clicked.  In HTML (HyperText Markup Language, the code used to write web pages), a hyperlink looks like this: <b> <a href="http://chillingeffects.org/linking/"></b>link<b></a></b>}
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Is "deep linking" illegal?},
 answer:   %{.
"Deep linking" refers to the creation of hyperlinks to a page other than a website's homepage. For example, instead of pointing a link at http://www.chillingeffects.org, this site's "homepage," another site might link directly to the linking FAQ at http://www.chillingeffects.org/linking/faq .  
<p>
Some website owners complain that deep links "steal" traffic to their homepages or disrupt the intended flow of their websites.  In particular, Ticketmaster has argued that other sites should not be permitted to send browsers directly to Ticketmaster event listings.  <a href="http://www.nytimes.com/library/tech/99/02/cyber/articles/15tick.html">Ticketmaster settled its claim against Microsoft</a> and <a href="http://www.gigalaw.com/library/ticketmaster-tickets-2000-03-27.html">lost a suit against Tickets.com</a> over deep linking. <blockquote class="main"><i>From <a href="http://www.gigalaw.com/library/ticketmaster-tickets-2000-03-27.html">Ticketmaster v. Tickets.com opinion</a></i>:<br>Further, hyperlinking does not itself involve a violation of the Copyright Act (whatever it may do for other claims) since no copying is involved. The customer is automatically transferred to the particular genuine web page of the original author. There is no deception in what is happening. This is analogous to using a library's card index to get reference to particular items, albeit faster and more efficiently.</blockquote>
<p>So far, courts have found that deep links to web pages were neither a copyright infringement nor a trespass.  }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Can linking be trademark infringement?},
 answer:   %{Trademark infringement is misuse of another's mark to cause consumer confusion about the source or sponsorship of goods or services.  By contrast, many non-confusing uses of trademarks are fair and/or non-infringing.  (See <!--GET CatLink 6--> Topic.) 

If website uses hyperlinks, like any other content, to mislead viewers into thinking the site is endorsed by someone whose trademark it uses, (e.g., "This page sponsored by MEGACORP, click here for more details"), the website might be found to infringe the trademark.   A website merely linking to someone's web page, even if that page and its <a href="http://webopedia.com/TERM/U/URL.html">URL</a> include a trademark (e.g., "We disagree with MEGACORP, click here to visit their homepage"), is unlikely to be trademark infringement.  }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Is framing of others' websites legal?},
 answer:   %{[not yet answered]}
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an operator of a visual search engine use the copyrighted images of another owner as "thumbnails" in its search engine?},
 answer:   %{Yes, the creation and use of "thumbnails" -- smaller, lower resolution depictions of the original image -- as part of such a search engine may be a fair use.  

The Ninth Circuit Court of Appeals recently held in Kelly v. Arriba Soft that displaying the copyrighed images of another as thumbnails on a search engine was a fair use because the thumbnails served a completely different purpose than the original images.  Working through the four factor fair use analysis, the court emphasized that it was essential to determine if defendant's use was transformative in nature.  It is more likely that a court will find fair use if the defendant's use of the image advances a purpose different than the copyright holder's, rather than merely superseding the object of the originals.  For example, the Ninth Circuit found there to be a fair use since the displayed images were not for illustrative artistic purposes, but were rather used as part of an image search engine as a means to access other images and web sites.  Even if defendant's website is operated for a commercial purpose, it may still be a fair use if the use of the image was "more incidental and less exploitative."  The court in Kelly found that defendant's search engine did not directly profit from the use of plaintiff's images, and therefore that their use was not highly exploitative.  In Kelly, the court also found that the use of the images would not hurt the plaintiff's market for the images.  

<a href="http://images.chillingeffects.org/cases/Kelly_v_Arriba.pdf">Kelly v. Arriba Soft Corporation</a>.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{How do I identify the owner of a domain name?},
 answer:   %{The quickest way is to use the global lookup tools such as <a href="http://www.geektools.com/cgi-bin/proxy.cgi">Geektools</a>, <a href="http://www.samspade.org/#TOC1">SamSpade</a>, or <a href="http://www.uwhois.com/cgi/domains.cgi?User=Default">uWhois</a> multi-registrar WHOIS services.    These are not authoritative directories, however, because they merely link to the databases of other directory services.

To verify actual registration data of a particular domain name, use the Whois tool hosted by the registry for the top level domain in question.  UniNett keeps a list of links to all <a href="http://www.norid.no/domreg.html">top level domain registries</a>.}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the most common mistake a Respondent makes in answering a Complain in a UDRP proceeding?},
 answer:   %{A naked denial, without providing any facts or evidence to support the denial.  For example, "I am not cybersquatting", or "I havenot acted in bad faith."}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the most common mistake a Respondent makes in answering a Complaint in a UDRP proceeding?
},
 answer:   %{A naked denial, without providing any facts or evidence to support the denial. For example, "I am not cybersquatting", or "I havenot acted in bad faith."
}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{How do lawyers "buy time" when a cease and desist letter is received by a client?},
 answer:   %{What a lawyer will often do to maintain the status quo is to send a response to the demand letter, within the stated time, saying something like this:  We are in receipt of your letter of (date)  "Please be advised that we are investigating the matter and will be in contact with you shortly."  This letter ordinarily gives additional time to research the allegations, and should give you some additional time to contact a lawyer if you need to. }
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Paris Convention and how does it apply to United States Trademark Law},
 answer:   %{Please see <a href="http://www.bitlaw.com/source/treaties/paris.html">Bitlaw</a> for an online copy of the Treaty; the applicable lanugage reads as follows: 

" (1)Any person who has duly filed an application for a patent, or for the registration of a utility model, or of an industrial design, or of a trademark, in one of the countries of the Union, or his successor in title, shall enjoy, for the purpose of filing in the other countries, a right of priority during the periods hereinafter fixed. 

(2) Any filing that is equivalent to a regular national filing under the domestic legislation of any country of the Union or under bilateral or multilateral treaties concluded between countries of the Union shall be recognized as giving rise to the right of priority."




 }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Should I accept a single panelist in UDRP proceeding?},
 answer:   %{There is a great risk for a Respondent in accepting a single panelist.  Statistics show that in an overwhelming majority of cases, where a single panelist is appointed by the organization chosent to arbitrate the matter, the Respondent has lost.}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{Should I accept a single panelist in UDRP proceeding?},
 answer:   %{There is a great risk for a Respondent in accepting a single panelist.  Statistics show that in an overwhelming majority of cases, where a single panelist is appointed by the organization chosent to arbitrate the matter, the Respondent has lost.}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{How should I go about selecting a panelist for a UDRP proceeding?},
 answer:   %{Check the track record of panelists to see how they have ruled in the past.  You want to make sure that some of the rulings have been in favor of Respondents. Also, make sure that the panelist is familiar with trademark law.  You can check the past rulings of the panelist at http://www.icann.org/udrp/udrpdec.htm}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{If a UDRP Complaint is filed against me, what are some of the facts I should attempt to demonstrate in my Response?},
 answer:   %{A. That you are not a competitor.
B. That you have not tried to sell the domain name to Complainant, or anyone else.
C. That you have a legitimate business (or any other) purpose for using the mark.
D. That you are not making trademark use of the word or phrase in which Complainant has trademark rights i.e. that you are using the word in its ordinary, every day, meaning and not as an indicator of source.
E. That Complainant's rights do not extend to your use of the trademarked word or phrase.}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I show that Complainant's trademark rights in a mark do not extend to my use of the mark in my domain name?},
 answer:   %{One way is by showing the mark is a common name or common word.  Using "Basset" as an example:
A. Conduct a white pages search on the Internet, or local phone books, to demonstrate the word is a common last name.
B. Using a search engine, such as "Google", show that the word has been used many times in many contexts not related to Complainant's field of use. 
C. (Attach this evidence to your Answer)
D. (Link to UDRP decision concerning Basset)

Of course that will only help you if you are using the term in a way that does not make people believe your site is run by the Complainant trademark holder, and outside the class of goods or services for which the trademark applies.}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find the text of the ACPA?},
 answer:   %{The <a href="http://www.mama-tech.com/1948.html">Anti-cybersquatting Consumer Protection Act</a> as enacted may be found at http://www.mama-tech.com/1948.html.

Most of the ACPA provisions are now found in the <a href="http://www.bitlaw.com/source/15usc/">Lanham Act</a> at <a href="http://www.mama-tech.com/names.html#acpa">15 USC 1125(d)</a>, <a href="http://www4.law.cornell.edu/uscode/15/1114.html">15 USC 1114</a> and <a href="http://www.bitlaw.com/source/15usc/1117.html">15 USC 1117</a>.}
)

mapping[%{ACPA}] << q.id

q = RelevantQuestion.create!(
 question: %{Who is behind the Chilling Effects project?},
 answer:   %{<p>The Chilling Effects Clearinghouse is a unique collaboration among law school clinics and the Electronic Frontier Foundation.  Conceived and developed at the <a href="http://cyber.law.harvard.edu/" target="new">Berkman Center for Internet & Society</a> by Berkman Fellow <a href="http://cyber.law.harvard.edu/seltzer.html" target="new">Wendy Seltzer</a>, the project is now supported by the following clinical programs: 
<!--GET display_list Org 1-->

The information and reports on the chillingeffects.org website are written by law students, under the supervision of the participating organizations.  Please see the <a href="about">About Us</a> page for more information and contacts.}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{I purchased the movie, book, etc. Doesn},
 answer:   %{Mere ownership of a book, manuscript, painting, or any other copy or phonorecord does not give the possessor the copyright in the work. The law provides that transfer of ownership of any material object that embodies a protected work does not of itself convey any rights in the copyright. 

So, a FanFic author who purchases a book and creates an animation of that book cannot claim that she owns the copyright of that book since she purchased it. Copyrights may be divided into mini-rights in different parts of the work and transferred but the law requires a written agreement for the assignment of any ownership interest. Authors are also generally allowed to terminate earlier transfers.  
}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What is vicarious liability?},
 answer:   %{Vicarious liability, a form of indirect copyright infringement, is found where an operator has (1) the right and ability to control users and (2) a direct financial benefit from allowing their acts of piracy.  User agreements or Acceptable Use Policies may be evidence of an operator's authority over users.  The financial benefit may include a subscription fee, advertising revenues, or even a bartered exchange for other copyrighted.  Under the doctrine of vicarious liability, you may be found liable even if you do not have specific knowledge of infringing acts occurring on your site.  
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{How can marketing affect FanFic?},
 answer:   %{ Copyright law gives an author the exclusive right to distribute to the public by sale or other transfer of ownership.  This means that if a fan of Superman digitally scans images of Superman from comic books and makes them available on the Internet, then this marketing could be a violation of the right to distribute (regardless of whether it was for- or not-for-profit).  (Note that if a fan purchases a copy of a Superman comic book legitimately, then the fan is free to sell of transfer that specific comic book without getting the prior consent of the copyright holder; this is called the "doctrine of first sale").

However, most FanFic works are not straight copies of another work; rather they are works that are often inspired by some book, movie or TV show.  Therefore, most FanFic authors are worried about whether they have violated an author's exclusive right to reproduce or prepare derivative works, rather than distribution.  In defense of their works, FanFic authors will often try to argue that their use constitutes fair use.  

Marketing activities by the FanFic author can impact the issue of fair use.  If the marketing activity is purely non-commercial, then this weighs in favor of the FanFic author.  }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What is reverse engineering?},
 answer:   %{Reverse engineering is the general process of analyzing a technology specifically to ascertain how it was designed or how it operates. This kind of inquiry engages individuals in a constructive learning process about the operation of systems and products. Reverse engineering as a method is not confined to any particular purpose, but is often an important part of the scientific method and  technological development.  The process of taking something apart and revealing the way in which it works is often an effective way to learn how to build a technology or make improvements to it.  

Through reverse engineering, a researcher gathers the technical data necessary for the documentation of the operation of a technology or component of a system. In "black box" reverse engineering, systems are observed without examining internal structure, while in "white box" reverse engineering the inner workings of the system are inspected. 

When reverse engineering software, researchers are able to examine the strength of systems and identify their weaknesses in terms of performance, security, and interoperability.  The reverse engineering process allows researchers to understand both how a program works and also what aspects of the program contribute to its not working.  Independent manufacturers can participate in a competitive market that rewards the improvements made on dominant products.  For example, security audits, which allow users of software to better protect their systems and networks by revealing security flaws, require reverse engineering. The creation of better designs and the interoperability of existing products often begin with reverse engineering.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{How does reverse engineering differ from other types of engineering?},
 answer:   %{The most traditional method of the development of a technology is referred to as "forward engineering." In the construction of a technology, manufacturers develop a product by implementing engineering concepts and abstractions.  By contrast, reverse engineering begins with final product, and works backward to recreate the engineering concepts by analyzing the design of the system and the interrelationships of its components.

Value engineering refers to the creation of an improved system or product to the one originally analyzed. While there is often overlap between the methods of value engineering and reverse engineering, 
the goal of reverse engineering itself is the improved documentation of how the original product works by uncovering the underlying design.  The working product that results from a reverse engineering effort is more like a duplicate of the original system, without necessarily adding modifications or improvements to the original design.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What stages are involved in the reverse engineering process?},
 answer:   %{Since the reverse engineering process can be time-consuming and expensive, reverse engineers generally consider whether the financial risk of such an endeavor is preferable to purchasing or licensing the information from the original manufacturer, if possible.

In order to reverse engineer a product or component of a system, engineers and researchers generally follow the following four-stage process:

<ul><li>Identifying the product or component which will be reverse engineered
<li>Observing or disassembling the information documenting how the original product works
<li>Implementing the technical data generated by reverse engineering in a replica or modified version of the original
<li>Creating a new product (and, perhaps, introducing it into the market)</ul>

In the first stage in the process, sometimes called "prescreening," reverse engineers determine the candidate product for their project.  Potential candidates for such a project include singular items, parts, components, units, subassemblies, some of which may contain many smaller parts sold as a single entity.

The second stage, disassembly or decompilation of the original product, is the most time-consuming aspect of the project.  In this stage, reverse engineers attempt to construct a characterization of the system by accumulating all of the technical data and instructions of how the product works.

In the third stage of reverse engineering, reverse engineers try to verify that the data generated by disassembly or decompilation is an accurate reconstruction the original system.  Engineers verify the accuracy and validity of their designs by testing the system, creating prototypes, and experimenting with the results.

The final stage of the reverse engineering process is the introduction of a new product into the marketplace.  These new products are often innovations of the original product with competitive designs, features, or capabilities.  These products may also be adaptations of the original product for use with other integrated systems, such as different platforms of computer operating systems.

Often different groups of engineers perform each step separately, using only documents to exchange the information learned at each step.  This is to prevent duplication of the original technology, which may violate copyright.  By contrast, reverse engineering creates a different implementation with the same functionality.
}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What is disassembly or decompilation of a computer software program?},
 answer:   %{In the development of software, the <a href="http://www.chillingeffects.org/reverse/faq.cgi#QID192">source code</a> in which programmers originally write is translated into object (binary) code. The translation is done with a computer program called an "assembler" or "compiler," depending on the source code's language, such as Java, C++, or assembly.  A great deal of the original programmer's instructions, including commentary, notations, and specifications, are not included in the translation from source to object code (the assembly or compilation).  

Disassembly or decompilation reverses this process by reading the object code of the program and translating them into source code.  By presenting the information in a computer language that a software programmer can understand, the reverse engineer can analyze the structure of the program and identify how it operates.

The data generated in the disassembly of a typical computer program is one to many files with thousands of lines of computer code.  Because much of the original programmer's commentary, notations, and specifications are not retained in the object code, the reverse engineered code constitutes only a part of the program information included in the original source code.  Engineers must interpret the resulting source code using knowledge and expertise to recreate the data structures of the original program and understand the overall design rationale of the system.

Not all reverse engineering efforts require "decompilation" of software. Some "black box" reverse engineering is done by characterizing software through observation of its interaction with system components, other software, and other (external) systems through networks.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between source code and object code?},
 answer:   %{Source code is the category of computer language instructions that is most frequently written and read by software programmers.  A computer cannot generally run a program in source code form though. The source code is translated, with the use of an assembler or compiler, into a language form that contains instructions to the computer known as object code. Object code consists of numeric codes specifying each of the computer instructions that must be executed, as well as the locations in memory of the data on which the instructions are to operate.

While source code and object code are commonly referred to as different classes of computer language, these terms actually describe the series of transformations a program goes through when being converted from a higher level language more easily comprehensible to humans to the lower level language of computer operations.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What is interoperability?},
 answer:   %{Generally, interoperability allows technologies to work together when they use the same inputs and create the same outputs. For computers, interoperability is the abililty of programs and systems running on various kinds of software and hardware to communicate with each other. 

Standards foster interoperability by ensuring that all groups implementing the standard interpret it the same way, so that the technology produces consistent performance regardless of the individual brand or model.  By contrast, a lack of standards means that parties must reverse engineer the technology to achieve interoperability.  Moreover, owners of proprietary, non-standardized technologies retain control over upgrades and developments to those technologies, and may change them at will, disrupting the interoperability with other technologies. }
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the different uses of reverse engineering?},
 answer:   %{A common misperception regarding reverse engineering is that it is used for the sake of stealing or copying someone else's work. Reverse engineering is not only used to figure out how something works, but also the ways in which it does not work.

Some examples of the different uses of reverse engineering include:
<ul><li>Understanding how a product works more comprehensively than by merely observing it
<li>Investigating and correcting errors and limitations in existing programs
<li>Studying the design principles of a product as part of an education in engineering
<li>Making products and systems compatible so they can work together or share data
<li>Evaluating one's own product to understand its limitations
<li>Determining whether someone else has literally copied elements of one's own technology
<li>Creating documentation for the operation of a product whose manufacturer is unresponsive to customer service requests
<li>Transforming obsolete products into useful ones by adapting them to new systems and platforms</ul>}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Is reverse engineering legal?},
 answer:   %{Reverse engineering has long been held a legitimate form of discovery in both legislation and court opinions. The Supreme Court has confronted the issue of reverse engineering in mechanical technologies several times, upholding it under the principles that it is an important method of the dissemination of ideas and that it encourages innovation in the marketplace. The Supreme Court addressed the first principle in <i>Kewanee Oil v. Bicron</i>, a case involving trade secret protection over synthetic crystals manufacturing by defining reverse engineering as "a fair and honest means of starting with the known product and working backwards to divine the process which aided in its development or manufacture." [416 U.S. 470, 476 (1974)] The principle that reverse engineering encourages innovation was articulated in <i>Bonito Boats. v. Thunder Craft</i>, a case involving laws forbidding the reverse engineering of the molding process of boat hulls, when the Supreme Court said that "the competitive reality of reverse engineering may act as a spur to the inventor, creating an incentive to develop inventions that meet the rigorous requirements of patentability." [489 U.S. 141 160 (1989)]

Congress has also passed legislation in a number of different technological areas specifically permitting reverse engineering.  The Semiconductor Chip Protection Act (SCPA) explicitly includes a reverse engineering privilege allowing semiconductor chip designers to study the layout of circuits and incorporate that knowledge into the design of new chips.  The Competition of Contracting Act of 1984 allows the defense industry to inspect and analyze the spare parts it purchases in order to facilitate competition in government contracts.

The law regarding reverse engineering in the computer software and hardware context is less clear, but has been described by many courts as an important part of software development. The reverse engineering of software faces considerable legal challenges due to the enforcement of anti reverse engineering licensing provisions and the prohibition on the circumvention of technologies embedded within protection measures.  By enforcing these legal mechanisms, courts are not required to examine the reverse engineering restrictions under federal intellectual property law. In circumstances involving anti reverse engineering licensing provisions, courts must first determine whether the enforcement of these provisions within contracts are preempted by federal intellectual property law considerations.  Under DMCA claims involving the circumvention of technological protection systems, courts analyze whether or not the reverse engineering in question qualifies under any of the exemptions contained within the law.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What "copying" of computer programs is permitted under copyright law?},
 answer:   %{Copyright law protects any work, including computer software, that is "fixed in a tangible medium of expression" and which contains a "modicum of originality."  While making a copy of an orginal work generally constitutes copyright infringement, the very nature of computer software requires the making of a copy of original elements every time a program runs. In order to solve this problem, Congress included specific exemptions within copyright law outlining the permitted uses of a computer program.

<a href="http://www4.law.cornell.edu/uscode/17/117.html">Section 117 of the Copyright Act</a> provides that:
<DL><DD>[I]t is not an infringement for the owner of a copy of a computer program to make or authorize the making of another copy or adaptation of that computer program provided:</dl>
<ul><ol>
<li type="1">that such a new copy or adaptation is created as an essential step in the utilization of the computer program in conjunction with a machine and that it used in no other manner, or</p>
<li type="1">that such new copy or adaptation is for archival purposes only and that all archival copies are destroyed in the event that continued possession of the computer program should cease to be rightful.</P>
</ul></ol>
}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Is the making of an intermediate copy in the reverse engineering process copyright infringement?},
 answer:   %{There have been many attempts by companies over the past two decades to bring claims against software developers for their reverse engineering efforts.  Since reverse engineers must make intermediate copies of the original work through the disassembly or decompilation process, the copyright owners of the initial software program have claimed that such a procedure is not covered by Section 117.  They have argued that reverse engineering should be considered copyright infringement since some of the retrieved technical data used in the development process includes copyrightable expression.

In <i>Sega v. Accolade</i>, the case most often referred to discussing reverse engineering of computer software, the appellate court determined that reverse engineering is a fair use when "no alternative means of gaining an understanding of those ideas and functional concepts exists."  The court considered Accolade's intermediate copying of parts of Sega's video game console during the reverse engineering process in order to make compatible games of minimal significance to the rights in Sega's copyrighted computer code.  The court held that forbidding reverse engineering in this context would defeat "the fundamental purpose of the Copyright Act--to encourage the production of original works by protecting the expressive elements of those works while leaving the ideas, facts, and functional concepts in the public domain for others to build on."
}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What elements of a computer program are copyrightable?},
 answer:   %{<a href="http://www4.law.cornell.edu/uscode/17/102.html">Section 102(b)</a> of the Copyright Act provides that:
<dl><dd>"in no case does copyright protection for an original work of authorship extend to any idea, procedure, process, system, method of operation, concept, principle, or discovery, regardless of the form in which it is described, explained, illustrated, or embodied in such work."</dl>

This principle that copyright protects the expression of an idea but not the idea itself is fundamental to copyright law. Commonly referred to as the "idea/expression dichotomy," this distinction is particularly complicated in the context of computer programs.  A software program must include many elements of computer code that are external to its particular use in order to function properly, including the specifications of the of the operating system, the computer on which the program runs, compatibility with other programs, and other widely accepted standards.  These functional elements of a software program as well as those aspects of the software code that are in the public domain are considered ideas not protected by copyright law.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{How does a court determine the difference between the ideas and expressions in a computer program?},
 answer:   %{In order to separate out those elements of a computer program that should be considered original expression from the unprotectable ideas and processes, courts utilize the Abstraction, Filtration, and Comparison test described in the case of <i><a href="http://eon.law.harvard.edu/openlaw/dvd/cases/Computer_Assoc_v_Altai.txt">Computer Associates v. Altai</a></i>. [982 F.2d 693 (2d Cir. 1992)] Under this test, the court is required to go through the following steps to determine whether copyright infringement occurred:
<ul><li>Retrace the designer's steps in the reverse order of its creation into manageable components in order to identify the unprotected ideas at each level of abstraction.
<li><sum> Filter out the non-protectable elements, including those dictated by efficiency (the most efficient implementation of any given task) , merger (when there is only one way to express an idea), external factors (necessity of matching standards), and elements taken from the public domain (expressions not protected by intellectual property).
<li>Compare the allegedly infringing work and the initial work to determine whether a sufficient similarity exists in the protectable elements of the initial work.</ul>}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Are the functional elements of a software program protected by copyright?},
 answer:   %{In applying the distinction between ideas and expressions, courts have analyzed particular features of software programs over the years in order to determine whether or not they should be protected.  While court decisions have varied according to the facts, copyright protection does not extend over the elements of a program's software code that relate to its basic function. For example, in <i>Lotus v. Borland</i> [49 F.3d 807 (1st Cir. 1995)], the court held that the menu command hierarchy and macros of a software program was not protectable since it embodied the basic structure and functionality of that type of program as a "method of operation."  Similarly, courts have considered whether certain program outputs such as portions of screen displays or graphical user interfaces (GUI) are protected by copyright. For example, the court in <i>Apple v. Microsoft</i> [35 F.3d 1435 (9th Cir. 1994)] held that Microsoft Windows did not infringe on the Macintosh OS because utilitarian aspects of the user interface such as the use of windows, icons, and menus were considered basic ideas to the "desktop" metaphor in the GUI of an operating system. The fact that such aspects of a program become industry standards is considered in the determination of whether they are functional elements not protected by copyright.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Is reverse engineering affected by patent law?},
 answer:   %{Though software programs had generally not been granted patents in the past, more recently the U.S. Patent Office has granted patents for those programs that meet the patent requirements of usefulness (it must work and have an actual use), novelty (it must not have been previously known), and non-obviousness (it must not be an obvious invention to an ordinary person in that field). Due to the additional requirement that the specifications of the invention must be disclosede in the published version of a patent, reverse engineering is generally not necessary to discover the method or process necessary to the independent creation of that invention. However, many integrated systems contain many components, some of which may be patentable, which may implicate a reverse engineer in a patent infringement lawsuit. Since electronic products often contain many constituent parts, made by a number of different manufacturers, it would not be possible to figure out how the whole product works without having to replicate some of its parts. Despite the first sale doctrine in patent law, which allows a purchaser of a product on the open market to use it and even take it apart, some courts have upheld contracts that specifically prohibit the reverse engineering of that product. The lack of a fair use exemption in patent law may threaten reverse engineering efforts when they involve software, but the question has not yet been addressed by courts.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Does trade secret protection of information contained within a product restrict reverse engineering?},
 answer:   %{Increasingly, manufacturers protect the know-how behind their software and electronics through the use of trade secret protection. This form of protection is attractive since the kinds of information that trade secrets is very broad and can include "any formula, pattern, device or compilation of information which is used in one's business, and which gives him an opportunity to obtain an advantage over competitors who do not know or use it." [Restatement of Torts, }
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Should a reverse engineer worry about the original product manufacturer's trademarks?},
 answer:   %{Software developers are generally not affected by a company's trademark when reverse engineering software. Trademark law protects words, names, symbols, or devices that identify the source of goods and services. While trademarks should not be a big concern for a reverse engineer , <i>Sega v. Accolade</i> was one case in which a manufacturer used trademarks to prevent the creation of programs compatible to its system.  Sega developed a trademark security system (TMSS) embedded in an initialization code on its games so that other companies could not develop games for the Sega Genesis console without infringing on Sega's trademark. The court did not find infringement because the SEGA trademark was used as an essential element of the functional device that regulates access.  Furthermore, the court held that this type of security system discouraged competition by excluding independently developed games from its video game market.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What kind of proof is necessary to show the copying of a computer program?},
 answer:   %{Courts determine whether or not copying occurred, rather that the independent creation of a program, by comparing the two programs for evidence of copyright infringement. The determination of copyright infringement is done through an analysis of whether there exists a "substantial similarity" between the initial work and the product of the reverse engineering effort.  Making such a determination can be quite complicated in the software context since different parts of the computer code may be similar due to the industry standards of the overall structure and user interface of programs as well as their compatibility requirements.  In order to prove a claim of copyright infringement, the burden is on the initial work's owner to show that the defendant had access to the original code.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What is UCITA?},
 answer:   %{The Uniform Computer Information Transactions Act (UCITA) is a proposed state law that would enforce the licensing provisions in click-wrap,shrink-wrap, and browse-wrap agreements.  These types of agreements are the most common types of transactions that occur in agreements over uses of computer information. There is a great deal of controversy over the inclusion of UCITA in contract law due to the effect it may have on the notice individuals have of the licensing provisions included and the ability of individuals to negotiate the terms of the contract. Whether or not an individual is sufficiently aware of the license terms to which they have agreed and the opportunity to bargain over these terms are important considerations in establishing a valid contract. Currently, UCITA is only in effect in two states - Maryland and Virginia. Several other states, though, have pending legislation that considers adopting UCITA as law. On the other hand, states such as Iowa have passed "bomb shelter" legislation in order to protect its citizens from being governed by UCITA.
}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between a license and a sale of a product?},
 answer:   %{As opposed to the transfer of ownership of property when a consumer buys a product, a licensee enters into a relationship with the manufacturer where the permitted uses of the product are defined in a contract and the manufacturer still retains ownership. The software industry generally makes end-user license agreements, which define these permitted uses in the form of a shrink-wrap, click-wrap, or browse-wrap agreement.  

Even though copyright law includes explicit exemptions on the use of computer programs under section 117 of the Copyright Act, some controversy exists over whether those exemptions apply in the case of a license that prohibits reverse engineering.  Under section 117, an <a href="http://eon.law.harvard.edu:8080/chilly/reverse/faq.cgi#QID196>(see above)</a>individual is permitted to make a copy of a program if the copy is made is part of the process of making a program interoperable with a machine</a>. Supporters of the enforceability of anti reverse engineering provisions argue that this exception does not apply to licenses because it is defined only in terms of ownership, which remains under the control of the manufacturer in a licensing agreement.  Opponents of such provisions argue that individuals do in fact own their copy of the program if it is the copyright in the program rather than the program itself which is transferred in the license.
}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What are shrink-wrap, click-wrap, and browse-wrap licenses?},
 answer:   %{In the context of computer software and the Internet, written agreements that indicate the formation of a contract between the user and the manufacturer have been replaced by shrink-wrap, click-wrap, and browse-wrap agreements. 

Shrink-wrap licenses refer to the cellophane wrapping that seals boxes of mass marketed software are commonly called "shrink-wraps." Software manufacturers generally attach license agreements inside the packaging of their products, which bind the consumer to the terms of the agreement upon removal of the shrink-wrap. 

Some courts have held that shrink-wrap licenses are unenforceable as contracts of adhesion, while other courts have considered them valid. An adhesion contract is a bargain drafted unilaterally by a dominant party, and presented as a final offer to a party with very little bargaining power. The terms are generally presented as a preprinted form to the weaker party, who lacks any realistic ability to negotiate the terms. If an individual chooses to return the product, however, they are no longer bound by the terms of the contract. 

Click-wrap licenses are another form of creating an electronic agreement, except that the license is included on the computer screen before installation rather than on the box. By clicking on a button that says "I agree" or "I accept," the licensee agrees to the terms of use of the contract. An important difference between click-wrap agreements and shrink-wrap agreements is the fact that the user actually has an opportunity to read the contract before using or installing the program.

Browse-wrap agreements are contracts in which the terms of use are listed on a web site page. In such contracts, manufacturers presume to bind the user to the license terms merely by their visit to the web site or downloading software from that site. Courts are generally reluctant to hold such contracts enforceable because of the lack of assent, or explicit agreement, on the part of the user.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Are licensing provisions prohibiting reverse engineering enforceable?},
 answer:   %{While the validity of licensing prohibitions of reverse engineering has not yet been decided by courts, the conflict between state laws that would enforce these provisions and federal intellectual property law has been addressed.  When considering cases where breach of contract or trade secret misappropriation is claimed (both state law claims), courts must first determine whether or not intellectual property law preempts those contracts enforced by the individual state. Preemption occurs when courts determine that federal intellectual property law must be considered in order to address the issues involved in the particular provisions.  

Section 301 of the Copyright Act provides that a state law claim is preempted if: 
<ol><li type="1">(1) the work to be protected comes within the subject matter of copyright; and 
<li type="1">(2) the state-created right forming the basis of the state law claim is equivalent to any of the exclusive rights within the general scope of copyright."</ol>

In order for the claim to be preempted it must first pass this equivalency test, which determines whether the state-created rights in upholding the contract are merely alternative articulations of the exclusive rights of copyright law.  If the court determines that the contract provisions contain an "extra element" that require analysis of the contract to be preempted by copyright law, the courts generally proceed to an analysis of the possible infringement or exemption under fair use of the activities of the reverse engineer.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Is the reverse engineering of a technological protection measure illegal under the DMCA?},
 answer:   %{The Digital Millennium Copyright Act (DMCA) made an effort to recognize the value of interoperability to competition and innovation and included an exemption expressly allowing reverse engineering in order to preserve a healthy market in the information technology industry.  <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#f">Section 1201(f)</a> of the DMCA allows software developers to circumvent technological protection measures of a lawfully obtained computer program in order "the elements necessary to achieve interoperability of an independently created computer program with other programs." A person may reverse engineer the lawfully acquired computer program only where the elements necessary to achieve interoperability are not otherwise readily available and reverse engineering is otherwise permitted under the copyright law. The reverse engineer is required to ask permission first, however. The prohibition on the dissemination of circumvention devices also applies to reverse engineering. Under the "trafficking ban", a person may only develop and employ technological means to circumvent and make the circumvention information or tool available to others solely for the purpose of achieving interoperability. Reverse engineers are not exempt from the "trafficking ban" only if they permit the device to be made available to other persons for the purpose of gaining access to protected works for infringing purposes.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the limitations of the interoperability criteria for the DMCA's reverse engineering exemption?},
 answer:   %{<a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#f">Section 1201(f)</a> allows software developers to circumvent technological protection measures of a computer program that was lawfully obtained in order to identify the elements necessary to achieve the interoperability of an independently created computer program to achieve <i>program to program</i> interoperability.  This means that reverse engineering a product to achieve interoperability between <i>data and program</i> is not permitted, nor is reverse engineering for any other purpose.  In <i>Universal v. Corley</i>, the district court in New York held that this limitation on the interoperability criterion of the exemption therefore did not apply to the circumvention of the access control mechanism protecting digitally formatted works, such as music, movies, or video games. In order to be viewed on a computer, motion pictures on DVD require software systems that enable the Content Scrambling System to be decrypted in addition to the hardware requirement of a DVD drive.  From the perspective of the consumer, the inability to view their DVDs on computer players that do not decrypt CSS may seem to be a problem of software interoperability.

The issue of whether or not the use of a technological protection measure can allow a copyright owner to control the hardware products on which the protected content can be used has not yet been fully addressed by the courts. By limiting the reverse engineering exemption to interoperability between programs, the DMCA may have effectively granted copyright owners some control over the hardware products used to operate digitally protected content in addition to the content itself.  Without consideration of the effect of technological protection measures, courts have held that copyright holders cannot use copyright to exercise control over products which are outside the scope of the owner's rights under copyright. For example, in the recent case of <i>Sony v. Connectix</i> (which did not include a DMCA claim), the Ninth Circuit held that a product allowing Sony games to be played on computers and not only on the Sony PlayStation was a creation of a new product.  The court considered the reverse engineering work engaged in during the creation of the product a "transformative" use of the initial copyrighted work, making it permissible according to copyright law. }
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{How are software development projects conducted over the Internet affected by the DMCA?},
 answer:   %{While the reverse engineering exemption permits software programmers to develop and distribute circumvention tools as part of their projects, there are significant limitations over who can do so and in what manner they can do it. <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#f_3">Section 1201(f)(3)</a> provides that only the person who performs the reverse engineering can provide the information necessary to achieve <a href="http://chillingeffects.org/reverse/faq.cgi#QID210">interoperability</a> to others. Collaborative project environments conducted over the Internet, such as those used by many open source software developers may be considered illegal under a strict interpretation of the exemption.  Even if the sharing of information regarding circumvention is done for the purpose of developing an interoperable product, its placement on the Internet may be interpreted as "trafficking" under the circumvention device ban.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{How is reverse engineering different from circumvention?},
 answer:   %{Circumvention, according to <a href="http://eon.law.harvard.edu/openlaw/DVD/1201.html#a_A">Section 1201(a)(3)(A)</a>, means "to descramble a scrambled work, to decrypt an encrypted work, or otherwise to avoid, bypass, remove, deactivate, or impair a technological measure, without the authority of the copyright owner."  Reverse engineering, on the other hand, is the scientific method of taking something apart in order to figure out how it works. While not all acts of circumvention require the use of reverse engineering, the reverse engineering of works protected by technological mechanisms requires circumvention.  The placement of digital protection systems on copyrighted works essentially fences in the information a reverse engineer seeks to discover about the way the product works.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a trade name?},
 answer:   %{Answer: A trade name is the actual name of the company. It may or may not also be a trademark. Trademarks are used to label specific goods or services; trade names identify the organization itself. For example, "Ford Motor Company" is a trade name as well as a trademark. "Bronco" is a trademark only. In those cases, if the trade name is registered as a domain name, the name owner is protected against cyber-squatting under traditional trademark provisions and also under the newer Anti-Cybersquatting Consumer Protection Act (ACPA) and the Uniform Dispute Resolution Policy (UDRP) of ICANN.

If a trade name is not used as a trademark, it may still be protected under other kinds of laws (having different criteria and remedies), such as unfair competition. However, if the trade name is registered as domain name, the owner will not be protected against cyber-squatting under the Anti-Cybersquatting Consumer Protection Act (ACPA) or the Uniform Dispute Resolution Policy (UDRP) of ICANN since they both apply only to trademarks.
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find federal trademark law?},
 answer:   %{To be protected by federal trademark law, the marked goods and services must be used in <i>interstate</i> commerce. Federal trademark law is known as the <a href="http://www.bitlaw.com/source/15usc/">Lanham Act.</a> It protects marks that are registered with the United States Patent & Trademark Office as well as those that are in use but never registered.

Court opinions and United States Patent & Trademark Office (USPTO) regulations also interpret trademark rights and remedies.  See the links to court sites provided by the <a href="http://www.bitlaw.com/trademark/index.html"> Legal Information Insitute.</a>}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find state trademark law?},
 answer:   %{Each state has its own laws governing use of trademarks within its borders. To locate the trademark laws of the 50 states, use the <a href="http://www.law.cornell.edu/topics/trademark.html">Legal Information Institute</a> links. Both legislation and court opinions create trademark rights and remedies. 

If marks are used in interstate commerce, then federal law will also apply.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What about common words that are used for many purposes?},
 answer:   %{Common words and alphabetical letters can be protectable trademarks if they are used in arbitrary or unusual ways.  One cannot trademark DIESEL to sell that generic type of fuel, otherwise no other diesel fuel dealer could use the word to identify the product.  However, one could trademark DIESEL as a brand of ice cream.  The owner of the ice cream mark can't use its rights to prevent fuel dealers from using the word on their station pumps nor can it prevent anyone else from using the word for non-trademark purposes, such as a website listing diesel fuel dealers.  

In general, the more a mark describes the good or service that it labels, the less strong the trademark protection it gets and the more freedom others have to use the same word for other purposes. 

See also this question on the <a href="http://www.chillingeffects.org/trademark/faq.cgi#QID252">strength of trademarks</a>.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Common Law Trademark?},
 answer:   %{Where consumers have come to identify a particular brand name with certain goods or services, US courts will protect the brand owner's rights, whether or not the brand has been registered with any governmental authority.  "Common law" refers to law made by judges in their court decisions, as opposed to the laws that are enacted by legislatures.  

In the US, registration is neither required to establish common law rights in a mark, nor to begin use of a mark. Common law trademark rights are limited to the geographic area in which the mark is used.  Most nations do not follow the common law system; they require formal registration rather than use in order to obtain for trademark protection.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What civil and criminal liabilities may be imposed for trademark infringement?},
 answer:   %{Under federal law (Lanham Act Section 32), an infringer shall be liable in a civil action by the registrant for certain remedies provided in the Act. 

One such remedy is an injunction, where a court orders a person who was found to violate the Act to stop its infringing activities. 

A trademark owner/registrant may also be able to obtain lost profits or damages against a defendant in a civil action only if the acts were committed with knowledge that such imitation was intended to be used to cause confusion, mistake, or to deceive. The trademark owner can recover (1) the domain holder's profits from use of the mark, (2) the trademark owner's damages resulting from harm to the value of mark, and (3) court costs as "actual damages." In determining the award to be paid, the court can choose to award up to three times the amount of actual damages. Instead of having to prove the amount of "actual" damages suffered as above, the mark owner can instead request payment of "statutory damages" from $1000 and $100,000 per domain name.

Attorney fees may be awarded in exceptional circumstances, such as when there was a willful and malicious violation. 

The court can order the cancellation or transfer of a domain registration.

In the case of a willful violation of Lanham Act section 43, a court may order that all labels, signs, prints, packages, wrappers, receptacles, and advertisements in the possession of a defendant bearing the registered trademark shall be delivered up and destroyed.}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the major elements of FanFic? },
 answer:   %{In general, FanFic involves a combination of established characters, established "worlds" (i.e., the setting or universe relating to the established characters) and established histories (the events described in the work involving the characters in their worlds) from current works. What FanFic authors add could include new characters, new worlds and new histories. Another form of adding originality is by detailing (or extending) certain characters, parts of worlds and histories that received little attention by the original author. The major possible violations are therefore copying, performance or display of existing characters and plots, creation of derivative works without the copyright holder's consent and prohibited use of trademarks belonging to the original work.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{I do not know what these cases or statutes cited in the C&D mean.},
 answer:   %{If your opponent has cited cases and statutes in the C&D, do not freak out. The fact that your opponent can include some legal authority in the C&D does not mean that the law is on its side. If you can, go look up the cases and statutes to see what they say. You can go to the nearest law school's law library for help, or you can try a free legal resource web site like <a href="http://www.findlaw.com">Findlaw</a>.  Many of them are accessible on the Internet by keyword search using the full case name or it's citation (the numbers and abbreviations that follow the names of the parties).

If your opponent is relying on federal law, it will probably cite one or more of the following sections of the Lanham Act: 
(1) section 32 (also known as <a href="http://www4.law.cornell.edu/uscode/15/1114.html">section 1114</a>); 
(2) section 43(a) [a/k/a <a href="http://www.bitlaw.com/source/15usc/1125.html">section 1125(a)</a>]; or 
(3) section 43(c) [a/k/a <a href="http://www.bitlaw.com/source/15usc/1125.html#(c)">section 1125(c)</a>]. (The smaller numbers indicate how the statutory sections were numbered when the law was a bill in Congress; the larger numbers indicate how the statutory sections were re-numbered when the law was codified in the U.S. Code. Under either numbering system, the laws say the same thing). An additional statute, the Anti-cybersquatting Consumer Protection Act (ACPA) [a/k/a <a href="http://www.bitlaw.com/source/15usc/1125.html#(d)">section 1125(d)</a> relates specifically to domain names.

Section 32 (codified as <a href="http://www4.law.cornell.edu/uscode/15/1114.html">15 U.S.C. 1114</a>) is the basic statute governing trademark infringement of registered marks. If you use a mark in commerce that is confusingly similar to a registered trademark, you may be civilly liable under section 32.  This section describes how to determine infringement, what the remedies are, and what defenses are available.

Section 43(a) [codified as <a href="http://www.bitlaw.com/source/15usc/1125.html">15 U.S.C. 1125(a)</a>] is the "false designation of origin" statute. If you use a mark in commerce that is likely to cause confusion or deception as to affiliation, association, origin, or sponsorship with another trademark, you may be civilly liable under section 43(a). Section 43(a) does not require that any of the marks be registered.

Section 43(c)[codified as <a href="http://www.bitlaw.com/source/15usc/1125.html#(c)">15 U.S.C. 1125(c)</a>] is the "anti-dilution" provision. This section allows the owner of a <i>famous</i> trademark to prevent use of the mark by junior users whose use }
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What about a fictional world and the events described in the world? Are they copyrightable? Can I use those in my story?},
 answer:   %{It seems unlikely that a FanFic work would include no previous characters but it is not impossible to imagine. Take Tolkien's "Middle-earth" world for example: this world has been taken without the main characters and has been used in role playing games (RPGs) and video games (see the TSR example below). For these cases, it is important to remember that copyright does not extend to ideas. Therefore, incidents, settings or other elements which are indispensable, or at least standard, in the treatment of a given topic are ideas and cannot be copyrighted. For example, the Court of Appeals for the Second Circuit has held that "elements such as drunks, prostitutes, vermin and derelict cars would appear in any realistic work about the work of policemen in the South Bronx." These "scenes a faire" are therefore unprotected. Likewise, the Seventh Circuit has held that mazes, tunnels and scoring tables are unprotected under the scenes a faire doctrine in video games like Duke Nukem. 
}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I tell if a character I have used is copyright protected?},
 answer:   %{The prevailing rule seems to be that a character is copyrightable separate from the original work if the character is "distinctly delineated." Authors can have a separate copyright protection for the characters in their works only if they have been developed and constitute original expression. Generic characters (the sidekick, for example) are not protected. Some courts require this delineation to be quite extensive, to the point that the character "constitutes the story being told." In Nichols v. Universal Pictures Corp., 45 F.2d 119 (2d. Cir. 1930), however, the court held that the character needs simply be more than just a "type" and this is achieved when they are drawn in considerable detail. If characters with visual images are involved (i.e., cartoons, movies, etc.), then courts are more likely to allow copyright protection because the visual image combined with conceptual qualities gives courts a more concrete sense of character delineation. (See Rocky IV example below).

But what if these elements were not just ordinary scenese a faire? What if these worlds were elaborately filled with details? Under the character analysis above, these worlds and events would probably also receive copyright protection. Again, the distinction is that normal plots like boy-meets-girl cannot be copyrighted (just like how stock characters like the "sidekick" are not copyrightable), but the more detailed the plot is, the more it becomes protectible expression.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Is FanFic an illegal act of creating derivative works?
},
 answer:   %{Copyright owners have the right to prepare derivative works based on the copyrighted work. In most cases the right to prepare derivative works is superfluous since when this right is infringed, the right to reproduction will also be infringed. For example, if a FanFic author creates a new story about Darth Vader, the author will have infringed both the derivative right and the right to reproduce that character.

As with a violation of the right to reproduction, the plaintiff will also need to show that the FanFic author copied from the original and that the new story is substantially similar to the original in expression. To be an infringement, the derivative work must be "based upon the copyrighted work," which refers to "a translation, musical arrangement, dramatization, fictionalization, motion picture version, sound recording, art reproduction, abridgment, condensation, or any other form in which a work may be recast, transformed, or adapted." Thus, to constitute a violation of section, the infringing work must incorporate some portion of the original work (see Distorted Barbie example below). For example, a detailed commentary on a work or a musical composition inspired by a book would not usually constitute infringements of this right.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What constitutes copyright infringement?},
 answer:   %{Subject to certain <a href="<!--GET URL Question 451-->">defenses</a>, it is copyright infringement for someone other than the author to do the following without the author's permission: <br>
1. reproduce (copy) the work;<br>
2. create a new work derived from the original work (for example, by translating the work into a new language, by copying and distorting the image, or by transferring the work into a new medium of expression);<br>
3. sell or give away the work, or a copy of the work, for the first time (but once the author has done so, the right to sell or give away the item is transferred to the new owner. This is known as the "first sale" doctrine: once a copyright owner has sold or given away the work or a copy of it, the recipient or purchaser may do as she pleases with what she posesses.) 17 U.S.C. ?109(a);<br>
4. perform or display the work in public without permission from the copyright owner. <a HREF="http://cyber.law.harvard.edu/property/library/copyrightact.html#anchor542164">17 U.S.C. ?106.</a> It is also copyright infringement to violate the "moral rights" of an author as defined by <a HREF="http://cyber.law.harvard.edu/property/library/copyrightact.html#anchor545352">17 U.S.C. 106A.</a> Moral rights are discussed <a HREF="http://cyber.law.harvard.edu/property/library/moralprimer.html">here</a>.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is an "inline" image?},
 answer:   %{An "inline" image refers to a graphic displayed in the context of a page, such as the picture to the right here.  <img src="/images/thermometer.gif" alt="image" align="right">  HTML (Hypertext Markup Language) permits web authors to "inline" both images from their own websites and images hosted on other servers.  When people complain about inline images, they are most often complaining about web pages that include graphics from external sources.  The legal status of inlining images without permission has not been settled.
}
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Robots Exclusion standard?},
 answer:   %{Robots (or 'bots or webcrawlers) are automated web browsers that "crawl" the web to retrieve web pages, for example on behalf of search engines or price comparison sites.  The  <a href="http://www.robotstxt.org/wc/exclusion.html">Robots Exclusion</a> standard is an informal convention many of these robots obey, by which webmasters can place a "robots.txt" file on the webserver to tell web robots to avoid some pages or entire sites. }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find the text of the UDRP?},
 answer:   %{The Uniform Domain-Name Dispute-Resolution <a href="http://www.icann.org/udrp/udrp.htm">Policy</a> is at <a href="http://www.icann.org/udrp/udrp.htm">http://www.icann.org/udrp/udrp.htm</a>.  The UDRP <a href="http://www.icann.org/udrp/udrp-rules-24oct99.htm">Rules</a> are at <a href="http://www.icann.org/udrp/udrp-rules-24oct99.htm">http://www.icann.org/udrp/udrp-rules-24oct99.htm</a>.  Each UDRP Provider has additional <a href="http://www.icann.org/dndr/udrp/approved-providers.htm">Supplemental Rules</a> which are linked from the ICANN <a href="http://www.icann.org/udrp/">UDRP page</a> at <a href="http://www.icann.org/dndr/udrp/">http://www.icann.org/dndr/udrp/</a> where there are also links to the large body of UDRP Panelist opinions interpreting the UDRP and materials on the history of the procedure.}
)

mapping[%{UDRP}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find the text of the U.S. Copyright Act?},
 answer:   %{The federal <a href="http://www.loc.gov/copyright/title17/">Copyright Act</a> may be found at <a href="http://www.loc.gov/copyright/title17/">http://www.loc.gov/copyright/title17/</a>.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I find out if someone has a valid trademark?},
 answer:   %{It isn't easy.  In the United States, a trademark owner isn't required to register the mark anywhere, so there is no single central list of them all.  Unlike most other nations, registration here is optional.  

Many owners do register their marks with the government, however, to better notify the world of their claims.  Each state has its own trademark registry for goods and services sold locally.  For companies that sell in more than one state, there is a US federal registry that is accessible online through <a href="http://tess.uspto.gov/">TESS</a>. TESS is searchable by key word as well as by registration number.

Because registration is not required, however, a word might still be a protected mark even if it doesn't appear in any of these locations.

When a company is selecting a new brand, its trademark attorney will usually conduct a "trademark availability" search which will look in many different locations to try and ferret out competing uses of the desired name.  Business directories, Internet search engines, telephone directories are other searched sources.  Multi-national vendors will search trademark registries in foreign nations as well. 

Even the most exhaustive search will not be conclusive, however, but it will usually indicate that if there is any other commercial use, it is probably limited to a very local area. It is OK to use the same mark as another company, so long as the new use isn't likely to confuse consumers.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find federal trademark registrations?},
 answer:   %{The United States Patent & Trademark Office (USPTO) keeps the US federal registry of trademarks.  It has an online search capability, <a href="http://tess2.uspto.gov/">TESS</a>, which contains more than 3 million pending, registered and dead federal trademarks. This database may not be complete.  One should check the <a href="http://tess2.uspto.gov/webaka/html/news.htm">News</a> page to see how current the information actually is.

Be aware: not all trademarks are contained in the US federal register.  There are state trademarks, unregistered (common law marks) and foreign marks as well.  A mark does not have to be registered to be valid.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Can the owner of a foreign trademark make any claim against me?},
 answer:   %{Trademark rights are limited to the territory of the government that grants them. The owner of a French trademark, for example, cannot block someone else from using the same term in New York.  However many courts around the world have held that they have authority to block Internet material because it "invades" their territory.

Can a foreign court order be enforced against you?  Maybe. If you have assets in that country, they could be seized.  If you visit that location, you could be arrested.  If your website host has assets in the foreign jurisdiction, however, the host might delete your material to avoid liability.  Domain names registered in certain TLDs (such as .com, .org and .net) can be lost to foreign mark owners under the <a href="<!--GET URL Cat 9-->">UDRP</a>, the special ICANN-imposed dispute procedure which protects every trademark owner in every country. 

If the French trademark owner also has a US mark, then it can sue you in US courts, but only under the US mark rights and only for the kind of activity that would be an infringement under US trademark laws.  US law protects free speech rights much more strongly than most foreign nations.

The truth is that anyone can make a claim even if a court would immediately reject it.  The mere threat of a claim is often enough to cause the person receiving the threat to give up when s/he doesn't understand his rights. }
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between a trademark and a service mark?},
 answer:   %{Trademarks refer to goods and products, that is, physical commodities which may be natural or manufactured or produced, and which are sold or otherwise transported or distributed.

Service marks refer to intangible activities which are performed by one person for the benefit of a person or persons other than himself, either for pay or otherwise.

Because the legal rights are essentially the same, the term "trademark" is frequently used to refer to both types of marks.

To learn about other types of marks, see <a href="http://www.uspto.gov/web/offices/tac/tmep/0100.htm">Chapter 100</a> of the USPTO's Trademark Manual of Examining Procedure.

To tell whether something is a good or a service, see <a href="http://www.bitlaw.com/source/37cfr/6_1.html">37 C.F.R. ?6.1</a>. }
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a trademark give someone rights in common words and letters?},
 answer:   %{Not all identifying names and phrases can be protected by trademarks. Protection depends on a mark's strength, which is determined by how it is categorized.  There are four categories (in descending order of strength):<OL><LI>arbitrary</li><LI>suggestive</li><LI>descriptive</li><LI>generic</li></ol>

An <B>arbitrary mark</b> receives the most protection since the name bears no relationship to the product -- it implies imagination and thought.  <I>Kodak</i> is an example of an arbitrary mark because the name itself suggests no connection to film or camera equipment. We learn this association only after the name has been used and becomes associated with the source of that product. A <B>descriptive mark</b> receives protection if it has <b>secondary meaning</b> in consumers' minds. A <B>generic mark</b> rarely receives protection because it is naturally associated with something in consumers' minds. An ordinary description is not special enough to warrant protection. However, if consumers connect the mark and its source in a way that would not exist without the mark's use in commerce, then the mark can be protected.<P>

Alphabet letters, initials, abbreviations and acronyms may be entitled to protection if they are so original that they constitute an <b>arbitrary mark</b> (e.g., NICAD for nickel cadium).  Otherwise, they may be protected only if they had acquired a <b>secondary meaning</b> which means that consumers have come to recognize the mark and associate the goods with a particular manufacturer (e.g., IBM and BMW).  }
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a trademark and why does it get special protection?},
 answer:   %{A trademark includes any word, name, symbol, or device, or any combination, used, or intended to be used, in commerce to identify and distinguish the goods of one manufacturer or seller from goods manufactured or sold by others, and to indicate the source of the goods. In short, a trademark is a brand name. 

Consumers reap the benefit when trademarks are protected.  By preventing anyone but the actual mark owner from labeling goods with the mark, it helps prevent consumers getting cheated by shoddy knock-off imitators.  It encourages mark owners to maintain quality goods so that customers will reward them by looking for their label as an indication of excellence.  Consumers as well as mark owners benefit from trademark laws.
 
Trademark owners spend a lot of time, money, and effort to protect the distinctiveness of their trademark.  Once trademarks have become diluted to the point where the general public no longer recognizes them as distinctly applying to a particular manufacturer, they lose their value to the trademark owner because they no longer attract customers to his particular goods. For example, ?aspirin? used to be the trademark of one particular manufacturer of synthesized acetylsalicylic acid, but is now used to generically describe that product regardless of who produces it. Trademarks owners must be vigilant to make sure that their trademarks rights are not being infringed and that their trademarks are not becoming diluted or generic.  
 
        The birth of the Internet and the use of character strings (domain names) to represent Internet addresses has presented trademark owners with a whole new set of problems.  It is often too expensive to register every variation of a trademark in every top level domain.  Therefore, trademark owners must make sure that the people who register domain names that are either the same as or confusingly similar to a trademark are not using the domain name in a way that infringes on the trademark.  One way to ensure that the trademark owner will not lose its rights in the mark is to file a UDRP complaint so that the Panel can decide whether the domain was registered in order to take unfair advantage of the mark owner.  The Panel may decide that the trademark owner was wrong and had nothing to worry about, but unless the trademark owner is vigilant and files the complaint, it may never know for sure whether its rights were being abused.
}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Isn't the domain name registration process "first come first served"?},
 answer:   %{In .com, .org and .net, which are "open" to any kind of registrant, the policy is first-come, first-served, as long as you have registered and used the domain name in good faith or have legitimate interests in the domain name.  However, you have no right to violate trademark law, or ignore your Registration Agreement, or engage in cybersquatting just because you registered the name first. 

Furthermore, in the newer domains such as .biz and .name, there are additional registration requirements that must be met because some of these domains are restricted. Trademark owners may also have advance registration rights. Check  individual registry requirements. See list of generic top-level domain registries at <a href="http://www.internic.net/faqs/new-tlds.html">http://www.internic.net/faqs/new-tlds.html</a>.}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Isn},
 answer:   %{Loaning someone your CD or even selling (but not renting) it is protected by U.S. copyright law since no additional copies are being made.  However, the copying necessary in internet transmission violates the exclusive rights of copyright holders.  Even in the case of streaming music, the right of }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "framing"?},
 answer:   %{Modern web browsers allow web authors to divide pages into panes or "frames".  Many sites use frames for navigation, putting a navigation bar in one frame and the main content in another.  Since it is possible for a site to call a frame's contents from a different location, a programmer might "frame" another's web content beneath his own navigation or banners.  See the <a href="http://www.totalnews.com/" target="new">TotalNEWS</a> site for an example of framing.  

The legal aspect of this web design are complex.  The creator of a frame does not literally "copy" the contents of the framed page, but the juxtaposition of pages may be claimed to create the mistaken impression of sponsorship or association. }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Is linking protected by the First Amendment?},
 answer:   %{The <a href="http://www.law.cornell.edu/constitution/constitution.billofrights.html#amendmenti">First Amendment</a> to the U.S. Constitution says that "Congress shall make no law ... abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble..."  The government (and states, under the Fourteenth Amendment) must meet a high level of scrutiny before restricting speech.

A hyperlinks refers to and describes the location of another Internet resource.  The text of the hyperlink and the material linked to may be highly expressive.  In addition, the act of linking to other websites may be likened to protected "assembly," or association with those sites.     }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{What defenses are there to copyright infringement?},
 answer:   %{.
The primary defense to copyright infringement is "fair use." <a HREF="http://cyber.law.harvard.edu/property/library/copyrightact.html#anchor548143">17
U.S.C. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{I have an unsettling feeling in the pit of my stomach about the tone of the C&D I received. Does the tone of the c & d mean I am going to lose this dispute?},
 answer:   %{"Gorilla Chest Thumping" refers to the tone of most C&Ds: it?s nasty. The first thing to do is take a deep breath. The second thing to do is to acknowledge that the tone of the letter is a function of the letter writer?s perception that aggression is the best defense: do not take it personally. The third thing to do is ignore the tone and focus on the facts. You may eventually choose to respond aggressively yourself, but do not do so because your opponent has egged you into a useless game of whose gorilla is bigger. Take a tip from Ani Di Franco: "If you play their game, girl, you?re never gonna win." <i>Face Up and Sing</i>, Out of Range, Righteous Babe Records (1994).}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is this laundry list of things the C&D says will happen if I don't obey?
},
 answer:   %{Your opponent may describe a parade of horribles to demonstrate with exquisite detail what it will do to you unless you capitulate. This list generally includes, but is not limited to: 
(1) ceasing use of the allegedly infringing mark or surrendering the domain name; 
(2) rendering an accounting; 
(3) posting corrective advertising; 
(4) obtaining an injunction; 
(5) recovering costs and fees. 

Though these things sound awful, they are not medieval tortures (although that may be a function of the fact that Torquemada never thought of them).

Ceasing use of the mark is self-explanatory: your opponent wants you to stop using the mark. Your opponent might also ask you to surrender your domain name if they believe the domain name causes (or is likely to cause) confusion with their trademark. For example, under ICANN rules (the <a href="http://www.chillingeffects.org/udrp/">UDRP</a>), you may have to surrender your domain name if the following three conditions are satisfied: 
(1) your domain name is identical or confusingly similar to your opponent?s;
(2) you have no legitimate right or interest in the name (in other words, you are not using the name to conduct a bona fide business or for non-commercial fair use purposes); and 
(3) your name is registered and used in bad faith.

An accounting basically means that you disclose the following information to your opponent: 
(1) the date you began using the allegedly infringing mark; 
(2) the names of individuals who knew of the use when it began; 
(3) the amount of traffic at your web site or business at your store; and 
(4) your profits and revenues during the time you used the allegedly infringing mark.

Corrective advertising means you give notice to the public that you were using a mark confusingly similar to your opponent?s, and that you are not affiliated with your opponent.

An injunction is a judicial order to do something. An injunction can prevent you from using the allegedly infringing trademark. 

Some provisions of the Lanham Act permit a trademark holder to recover attorney?s fees and court costs from an infringer.

That your opponent has listed these various remedies does not mean that it is entitled to them; do not confuse the smorgasbord of legal options with your opponent?s right to inflict any of them on you.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What facts should a C&D include?
},
 answer:   %{Recitation of Facts.  Read this section of the letter carefully. It should contain some or all of the following information: 
(1) the trademark that is allegedly being infringed; 
(2) the trademark, domain name or other use that is allegedly doing the infringing; 
(3) the products and services on which your opponent uses the allegedly infringed mark; 
(4) the date your opponent commenced such use; and 
(5) the registration numbers, if the trademarks are registered with the Patent & Trademark Office.


}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the bare minimum of trademark law that I have to understand to decipher this C&D?
},
 answer:   %{Your opponent should say that your mark is causing consumer confusion or is likely to cause consumer confusion. Or it should mention it's famousness and complain of dilution or tarnishment. (If the C&D does not say this, then no trademark claim may actually exist, and you can rest assured that your opponent is engaging in scare tactics or has hired a highly incompetent attorney). A mark  protects more than identical copying, it extends to anything that is confusingly similar, even if it isn't exactly the same.

Functioning in a quasi-magical talisman-like capacity, trademarks designate the source or quality of goods or services. For this reason, the law protects against confusion in the market place by ensuring that marks on the same or similar products or services are sufficiently different. The law also protects famous marks against dilution of value and tarnishment of the reputation of the goods or services on which it appears or the source of those products, regardless of any confusion. 

You can roughly assess the validity of your opponent?s claim of confusion by classifying the marks involved.  A trademark can fall into one of 5 categories. It can be: (1) fanciful; (2) arbitrary; (3) suggestive; (4) descriptive; or (5) generic. Not all of these varieties of marks are entitled to the same level, or indeed any level, of trademark protection. 

A fanciful mark is a mark someone made up; examples include KODAK or H?AGEN-DAZS. An arbitrary mark is a known term applied to a completely unrelated product or service; for instance, AMAZON.com for an online book-store cum one-stop shopping site or APPLE for computers. Fanciful and arbitrary marks are considered strong marks and garner substantial trademark protection. 

A suggestive mark is one that hints at the product, but which requires an act of imagination to make the connection: COPPERTONE for sun tan lotion or PENGUIN for coolers or refrigerators are examples. Suggestive marks are also strong marks and receive protection. 

A descriptive mark, predictably, describes the product: HOLIDAY INN describes a vacation hotel and FISH-FRI describes batter for frying fish. Descriptive marks do not receive any trademark protection unless their user has used them in commerce and has built up secondary meaning. "Secondary meaning" occurs when consumers identify the goods or services on which the descriptive term appears with a single source. In other words, if consumers know that HOLIDAY INN hotels are all affiliated with a single source, then the mark has secondary meaning and receives trademark protection. 

Finally, generic marks simply designate the variety of goods involved: for example, "cola" used on soft drinks and "perfume" on perfume are both generic terms. Generic marks never receive any trademark protection; they are free for everybody to use. (Keep in mind, though, that "Cola" on a nightclub is arbitrary, and therefore receives protection).

If your opponent is complaining that you have used the word "bakery" for a bake shop or "car" for a car repair shop, then you can safely guess that the c & d is baseless. On the other hand, if your opponent is concerned about the fact that both of you use of the term "Sweet Pickles" on alpaca sweaters, then the c & d may have some merit. 

There are a few more wrinkles as well.  Some marks are word marks (text only) and others are design marks (images which may or may not include text).  Design marks do not provide independent protectin for the text incorporated in the design.  So if the mark is only a design mark, it doesn't prevent others from using the text so long as they don't copy the design elements.  }
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What do these registration numbers mean? or Why don},
 answer:   %{Do not be led astray by the registration numbers: trademark rights in the United States arise from use of the mark in commerce, not from registering. However, both state and federal law can provide relief from trademark infringement.
 
If your opponent has registered its mark on the Patent & Trademark Office}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the product or service on which I am using the mark matter?  Do dates matter?
},
 answer:   %{It matters if the mark is not famous.  The C&D should disclose your opponent?s products and/or services and the date on which it commenced use of the allegedly infringed mark. This will help you guesstimate whether a likelihood of confusion between the marks exists. For instance, if your opponent uses ?opera? on truffles and you use "opera" on silk gloves, consumers are not likely to confuse the products.  If the mark is determined by a court to be famous, however, confusion is irrelevant and [non-fair] use on any type of goods may be an infringement.

The date on which your opponent began using the mark is significant because a junior (later) user cannot displace a senior (first) user in the senior user?s geographic region. In other words, if you have owned a chain of donut shops called "Lucky Donuts," with locations in New Jersey, New York, and Connecticut since 1943, a national chain called "Lucky Donuts" founded in 1979 has no trademark infringement claim against you in the NJ-NY-CT tri-state area. If your opponent has begun using its allegedly infringed mark after your use, you have another reason to question the merit of the C&D.
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{How do you know what trademarks are involved? },
 answer:   %{The C&D should identify your opponent}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{I did not know that what I was doing could be illegal. Am I off the hook?},
 answer:   %{No. Copyright infringement actions do not require that you actually knew that the files were protected by copyright or that your use of the files violated federal law. Claims of ignorance cannot be used as a defense to direct copyright infringement,   Lack of knowledge, is, however, a defense to contributory infringement.
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{I run a website but I never actually upload or download copyrighted materials. Could I be liable for what visitors to my site do?},
 answer:   %{You could.  Bulletin board operators and webmasters can be subject to both civil and criminal liability for indirect copyright infringement when unauthorized copies of software (or the direct means to obtain such software) are found on their sites. You may be subject to allegations of direct copyright infringement, or one of two different indirect claims:  vicarious liability and contributory infringement.  It is important to realize that such liability may be avoided altogether if you comply with the provisions of the DMCA [LINK].
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{How can a webmaster directly infringe copyright?},
 answer:   %{Courts are split on whether an operator of a web site that simply acts as a conduit for others to share information may be found directly liable for copyright infringement.  Though technically, even a passive operator violates the copyright holder's exclusive right to distribute and display their materials, most courts have required an affirmative step by the operator to further the infringement.  Thus creating and maintaining a system where others may post pirated software and information that helps others obtain pirated software would not generally be sufficient whereby actively participating and encouraging the piracy would be.  Posting any tools which help users circumvent copy protection ("cracker utilities") is also prohibited by }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is vicarious liability?},
 answer:   %{Vicarious Liability is a form of indirect infringement found where an operator had the ability and authority to control users in addition to a financial incentive for allowing their acts of piracy.  Control can be shown through language and rules imposed in user agreements listed on a website or required as part of an agreement with an ISP.  The financial incentive may be a subscription fee, advertising revenues, or even a bartered exchange of other software.  You may be found liable even if you do not have specific knowledge of infringing acts occurring on your site.  Thus, even if you are not aware that users are uploading and downloading unauthorized copies of software or posting cracker utilities, you may be liable.
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is contributory infringement?},
 answer:   %{The other form of indirect infringement, contributory infringement, requires (1) knowledge of the infringing activity and (2) a material contribution -- actual assistance or inducement -- to the alleged piracy.  

Posting access codes from authorized copies of software, serial numbers, or other tools to assist in accessing such software may subject you to liability. Providing a forum for uploading and downloading any copyrighted file or cracker utility may also be contributory infringement.   Even though you may not actually make software directly available on your site, providing assistance (or supporting a forum in which others may provide assistance) in locating unauthorized copies of software, links to download sites, server space, or support for sites that do the above may contributorily infringe.  
  
To succeed on a contributory infringement claim, the copyright owner must show that the webmaster or service provider actually knew or should have known of the infringing activity.  }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What does the "reservation of rights" language mean?  What are they "waiving" at me?},
 answer:   %{Many C&Ds will say something like, "This letter shall not be deemed to be a waiver of any rights or remedies, which are expressly reserved." This is just legalese for saying, "Even if you do what we ask in this letter, we can still sue you later." The language is standard; do not be alarmed. Litigation is extremely unpleasant, and unless your opponent is irrational (always a distinct possibility, of course), it will not bring litigation after it has obtained what it wants.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Isn't sending my friend a music file from a CD I already own just like loaning her the physical CD?
},
 answer:   %{Loaning someone your CD or even selling (but not renting) it is protected by U.S. copyright law since no additional copies are being made.  However, when you send a music file to someone else, you retain your copy and an additional copy is made.  This copying may violate the exclusive rights of copyright holders.  
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What if the alleged infringement happens outside of the U.S.?
},
 answer:   %{International rules including the TRIPs Agreement and the Berne Convention allow the U.S. to enforce its copyright rules under local laws in over 100 participating nations.
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What Are the Penalties for Pirating Software?
},
 answer:   %{In a civil suit, an infringer may be liable for a copyright owners actual damages plus any profits made from the infringement.  Alternatively, the copyright owner may avoid proving actual damage by electing a statutory damage recovery of up to $30,000 or, where the court determines that the infringement occurred willfully, up to $150,000. The actual amount will be based upon what the court in its discretion considers }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{I didn},
 answer:   %{No. Copyright infringement actions do not require that you actually knew that the files were protected by copyright or that your use of the files violated federal law. Claims of ignorance cannot be used as a defense to direct copyright infringement,   Lack of knowledge, is, however, a defense to contributory infringement [LINK].  
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{I run a website but I never actually upload or download copyrighted materials. Could I be liable for what visitors to my site do?
},
 answer:   %{You could.  Bulletin board operators and webmasters can be subject to both civil and criminal liability for indirect copyright infringement when unauthorized copies of software (or the direct means to obtain such software) are found on their sites. You may be subject to allegations of direct copyright infringement, or one of two different indirect claims:  vicarious liability and contributory infringement.  It is important to realize that such liability may be avoided altogether if you comply with the provisions of the DMCA [LINK].
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{How can a webmaster directly infringe copyright?
},
 answer:   %{Courts are split on if an operator of a web site that simply acts as a conduit for others to share information may be found directly liable for copyright infringement.  Though technically, even a passive operator violates the copyright holder}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{How can a webmaster directly infringe copyright?
},
 answer:   %{Courts are split on if an operator of a web site that simply acts as a conduit for others to share information may be found directly liable for copyright infringement.  Though technically, even a passive operator violates the copyright holder}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{So am I better off not monitoring my website if I want to avoid contributory infringement liability?
},
 answer:   %{Even though not actually knowing about a violation occurring on your website may shield you from contributory infringement liability, a }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Am I protected by Digital Millennium Copyright Act's Safe Harbor?},
 answer:   %{You may be, if you follow the DMCA's strict requirements, though different courts have disagreed on how to apply the protections.  The DMCA, in the Safe Harbor provisions of 17 U.S.C. 512, limits the liability of  "online service providers" (OSPs) for copyright infringement by their users.  Though some debate remains over who qualifies as an OSP, the rule's history suggests that website and bulletin board operators qualify for its protections.  The Safe Harbors apply to:
1.      Storage of material on a system at a user's request.  (e.g. pirated software, serial numbers or cracker utilities posted on message boards or in chat rooms)
2.      Referral to other online resources. (e.g. linking to other sites that make infringing material available)
3.      Caching of online materials from other sites.  (e.g. temporary storage of other web pages on one's own server)
4.      Acting as a conduit between users. (e.g. automatic delivery of e-mail between users)

In order to be protected for storage and linking (1 and 2, above), you must:
i.      Lack actual knowledge and immediately remove or block access to the material when becoming aware of the infringement
ii.     Not benefit financially from the activity
iii.    Comply with the notice and takedown provisions and set up an agent to deal with complaints in accordance with the Act

In order to be protected for acting as a conduit (4, above):
i.      A person other than the OSP must initiate the transmission
ii.     The process must happen automatically, without any selection or modification of material or recipients by the OSP
iii.    No copies of the material should be kept longer than necessary by the OSP

}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I copy or distribute software that is out of print and has been abandoned for years?
},
 answer:   %{The right to }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Aren},
 answer:   %{This is another myth without basis in U.S. Copyright law.  Test periods are allowed only with explicit permission from a copyright owner as in licensed trial versions of software.  Because sampling involves making a copy of the work, one of the rights explicitly reserved to copyright owners in }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the penalties for copyright infringement?},
 answer:   %{In a civil suit, an infringer may be liable for a copyright owners actual damages plus any profits made from the infringement.  Alternatively, the copyright owner may avoid proving actual damage by electing a statutory damage recovery of up to $30,000 or, where the court determines that the infringement occurred willfully, up to $150,000. The actual amount will be based upon what the court in its discretion considers }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the penalties for copyright infringement, such as making infringing copies of software?},
 answer:   %{In a civil suit, an infringer may be liable for a copyright owner's actual damages plus any profits made from the infringement.  Alternatively, the copyright owner may avoid proving actual damage by electing a statutory damage recovery of up to $30,000 or, where the court determines that the infringement occurred willfully, up to $150,000. The actual amount will be based upon what the court in its discretion considers just. (<a href="http://www4.law.cornell.edu/uscode/17/504.html" target="new">17 U.S.C. 504</a>)

Violation of copyright law is also considered a federal crime when done willfully with an intent to profit.  Criminal penalties include up to ten years imprisonment depending on the nature of the violation. (<a href="http://www4.law.cornell.edu/uscode/18/2319.html" target="new">No Electronic Theft Act, 18 U.S.C. 2319</a>)
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Why are copyright holders concerned about piracy?
},
 answer:   %{Free speech is protected by the U.S. Constitution but so are property rights.  Copyright law provides incentives for creating. One of the incentives for creating software, music, literature and other works is being able to reap the financial benefits as the creator. Illegitimate distribution of copies may prevent the copyright holder from benefiting from the sale of legitimate copies of the product. The theory is that significantly fewer people would buy copies from the copyright holder if other copies were available cheaper or for free. 
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{I run a website but I never actually upload or download copyrighted materials. Could I be liable for what visitors to my site do?},
 answer:   %{You could.  Under certain circumstances, bulletin board operators and webmasters can be subject to both civil and criminal liability for contributory or vicarious copyright infringement when unauthorized copies of software (or the direct means to obtain such software)  are found on their sites.  If you know that people are using your site to find warez or cracked video games, you may have an obligation to do something about it, particularly if you benefit financially in any way, or are able to control the unlawful copying.  You can protect yourself by complying with the  <!--GET FAQLink 14-->.}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{I purchased the movie, book, etc. Doesn},
 answer:   %{Mere ownership of a book, manuscript, painting, or any other copy or phonorecord does not give the possessor the copyright in the work. The law provides that transfer of ownership of any material object that embodies a protected work does not of itself convey any rights in the copyright. 

So, a FanFic author who purchases a book does not also purchase the right to create a derivative work based on that book, for example a new story or a comic.    
}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{How long does a copyright last?},
 answer:   %{A copyright could be invalid if the term of its protection has expired. A work that is created on or after January 1, 1978 is ordinarily given a term enduring for the author's life plus an additional 70 years after the author's death (otherwise known as }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{How likely is copying to be found (by a court) and what are the possible remedies?},
 answer:   %{As mentioned in the legal introduction (see "Is there an infringement?"), a plaintiff must meet certain requirements in order to show that a FanFic author copied protected expression. In order to prove copying, it must be shown that the fan fiction author copied the work (either through direct or indirect evidence), and some of the copied elements are protected and that the "audience" of the work would also find similar elements. Since FanFic authors generally do not deny that characters and settings are borrowed ("copied"), as seen in their disclaimers, it is likely that copying will be found. Then you must raise the defense of fair use.   

What happens if I lose the case? If the court finds that you unlawfully copied, it has several possible options. First, and most likely, an injunction could be granted to prevent the author from publishing and distributing the FanFic. The infringing materials could even be destroyed. The court also has the power to award monetary damages. The amount of damages would depend on the lost revenue suffered by the copyright owner and possible profits earned by the FanFic author. Generally, the loss of revenue is rare since FanFic does not draw audiences away from the original; rather, FanFic often serves to enhance sales of the original work. And if FanFic is not for profit, then it is unlikely that the author will have any profits to report. Since there is seldom lost revenue and profits, plaintiffs will often go for "statutory damages." This award can be between $200 (innocent infringement) and $100,000 (willful infringement) for each work infringed.
}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What if I used false contact information in my domain name registration?},
 answer:   %{False or fictitious domain registration information is a basis for finding "bad faith" registration or use of the domain name and this can cause the domain holder to lose his/her domain under the Anticybersquatting Consumer Protection Act (<!--GET CatLink 10-->) and under the Uniform Domain Name Dispute Resolution Procedure (<!--GET CatLink 9-->). See the topic on <!--GET CatLink 13--> for arguments in favor of protecting online anonymity.}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a Private Transaction Request?},
 answer:   %{VeriSign's Private Transaction Request is one of many escrow services that offer to protect the integrity of a domain name transfer between two parties who aren't in physical contact with each other.  It's not about privacy, it's about security.

Suppose someone offers to buy your domain for a million dollars.  If you execute the transfer order before getting the cash, you might never get the money afterward. If you are the buyer and you send your check to the seller, what if she never issues the transfer order to the registrar?  Domain transfer escrow services will hold the buyer's money in trust and release it to the seller only after the transfer order has been executed. For details about how one escrow service actually works, see AFTERnic.com's <a href="http://www.afternic.com/index.cfm?a=help&sa=closings&tab=about">DNESCROW</a> site.

Where the transaction does not involve signifcant money or risk, the normal cost to transfer a domain is less than $30 and can easily be executed by the domain seller online.  See, for example, <a href="http://www.dotster.com/special/transfer.asp">Dotster</a>. }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What implication does alleged confusion have on claims of trademark infringement?},
 answer:   %{.A mark that is confusingly similar so closely resembles a registered trademark that it is likely to confuse consumers as to the source of the product or service. Consumers could be likely to believe that the product with the confusingly similar mark is produced by the organization that holds the registered mark. Someone who holds a confusingly similar mark benefits from the good will associated with the registered mark and can lure customers to his/her product or service instead. Infringement is determined by whether a given mark is confusingly similar to a registered mark. The factors that determine infringement include:
<ul><li>proof of actual confusion
<li>strength of the established mark
<li>proximity of the goods in the marketplace
<li>similarity of the marks' sound
<li>appearance and meaning
<li>how the goods are marketed
<li>type of product and how discerning the customer is
<li>intent behind selecting the mark
<li>likelihood of expansion in the market of the goods
</ul>}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "intellectual property"?},
 answer:   %{Intellectual property refers to the rights one has in the product of one's intellect.  This includes copyright (rights in creative expression)and patents (rights in inventions, discoveries, methods, compositions of matter, etc.) which are granted by article I, section 8 clause 8 of the US Constitution which gives Congress the power to "To promote the Progress of Science and useful Arts, by securing for limited Times to Authors and Inventors the exclusive Right to their respective Writings and Discoveries." 

Related rights include trademark (rights in the names one uses to identify one's goods and services), trade secret (confidential business practices), unfair trade practice, passing off, trade libel, false advertising, misappropriation.  Laws protecting most of these rights exist at both the state and federal level.  "Proprietary rights" is just a general term meaning "one's own rights." }
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{How do companies usually react to FanFic?},
 answer:   %{Different companies have different methods in dealing with FanFic. Some, like Paramount Pictures, see that FanFic could actually help boost their sales and so encourage the writing of FanFic. Other companies are presumably waiting for more business information and legal clarity before making a decision. For example Universal, which owns the rights to Xena: the Warrior Princess, have yet to go after the numerous copyright violations involving what fans dub the "Xenaverse." The Universal approach is in sharp contrast to Fox Television and Viacom, both of whom resort to harsh cease-and-desist letters against unauthorized Web site creations by fans of such shows as "The X-Files," "Millennium" and "Star Trek." 

In order for a corporation to win a cease-and-desist order against a FanFic author, it would have to prove that it was suffering financial damage, something that is hard to prove since much of FanFic actually helps boost sales. This has helped motivate companies to go after ISPs. Being caught in the middle of the battle, ISPs will often put pressure on the FanFIc authors in order to avoid liability, a decision which often leaves FanFic authors without any choice but to remove the supposedly offending material. }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{How do companies usually react to FanFic?},
 answer:   %{Different companies have different methods in dealing with FanFic. Some see that FanFic could actually help boost their sales and so encourage the writing of FanFic. Other companies are presumably waiting for more business information and legal clarity before making a decision. For example Universal, which owns the rights to Xena: the Warrior Princess, have yet to go after the numerous possible copyright infringements involving what fans dub the "Xenaverse." The Universal approach is in sharp contrast to Fox Television and Viacom, both of whom have resorted to harsh cease-and-desist letters against unauthorized Web site creations by fans of such shows as "The X-Files," "Millennium" and "Star Trek." 

In order for a corporation to win a cease-and-desist order against a FanFic author, it would have to prove that it was suffering financial damage, something that is hard to prove since much of FanFic actually helps boost sales. This has helped motivate companies to go after ISPs. Being caught in the middle of the battle, ISPs will often put pressure on the FanFIc authors in order to avoid liability, a decision which often leaves FanFic authors without any choice but to remove the supposedly offending material. }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What liabilities could ISPs face? (And what can FanFic authors expect from their ISPs?)},
 answer:   %{As more companies deal with FanFic through ISPs, it is important for ISPs and FanFic authors to know what rights they have. The Digital Millennium Copyright Act ("DMCA") establishes a "safe harbor" from liability for ISPs that exercise no control over content other people provide.  If your ISP fits under the safe harbor provisions, then it will not face monetary damages, only a possible injunction.  Under the safe harbor provisions, you as the author are entited to notice that the ISP might take your story down, and you can issue a counter-notice claiming that your work is not infringing.  For more on how the DMCA Safe Harbor counter-notification procedures can protect your work, click here<!--GET CatLink 14-->.  

The DMCA also has certain other procedural requirements that allocate the burdens between copyright holders, ISPs and individuals. Specifically, the copyright holder has the burden to find the ISPs that carry the offending material. The ISP then has the burden to send notice to the offending users. The user then has the right to file a counter-notice for fair use or some other defense, at which point the ISP can remove itself and let the copyright holder and the user fight it out. If the ISP is found to be secondary liable (see "Is there an infringement"), then it pays no monetary damages and suffers only the possibility of an injunction. Nonetheless, ISPs generally prefer less liability and will often exert enough pressure on the individual such that the individual complies or is forced to find another ISP. With little resources, it is only expected that individuals face the brunt of this burden allocation. (See the DMCA section of this website for more information).
}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What benefit does an author credit provide?},
 answer:   %{A credit serves as a disclaimer.  Strictly speaking, disclaimers do not absolve an infringer from liability. However, disclaimers do serve an important function. Disclaimers explain the purpose and extent of the borrowing author's use and show that they recognize their "borrowing." Thus, disclaimers help appease original authors' fear that they will lose control over their works. The acknowledgment of the original source and ownership of the original work can reinforce the communal aspects of fandom and show that the borrowing authors respect original author's rights. }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What are some examples of copyright actions against FanFic authors?},
 answer:   %{[not yet answered]}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{When is a trademark issue involved in FanFic?},
 answer:   %{Trademark law is intended to protect two areas: 1) the protects the public's interest in being able to accurately ascertain the source of goods and services in the market; and 2) to protect a business's good will. Sometimes this takes the form of direct competition between two users of similar marks. Other times, someone who uses a confusingly similar mark may suggest an affiliation with the true mark owner even where there is no direct competition, which might lead consumers to wrongly attribute possible mistakes or poor quality in the good or service. In either scenario, however, it is important to remember that a good or service is involved. Also, the fact that a good or service is free of charge does not necessarily prevent liability. Thus, FanFic authors who actively distribute a good or service could face trademark liabilities.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What are some examples of trademark actions against FanFic authors?},
 answer:   %{[not yet answered]}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What are some examples of trademark actions against FanFic authors?},
 answer:   %{[not yet answered]}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Slander Per Se?},
 answer:   %{Slander is a defamatory statement expressed in a transitory medium, such as verbal speech. It is considered a civil injury, as opposed to a criminal offence.  The tort of slander is often compared with that of libel, which is also characterized as a defamatory statement, but one made in a fixed form, such as writing. 
Slander Per Se is slander for which special damages (e.g. actual loss in revenue) need not be proved in order to recover general damages (e.g. for emotional distress).  Slander Per Se only applies to slanderous publications which imputes to the plaintiff one of the four following categories:  
1)a crime involving moral turpitude, 
2)a loathsome disease (e.g. a sexually transmitted disease), 
3)Unchastity (particularly concerns women)
4)conduct that would adversely affect ones business or profession

General damages are presumed legitimate even in abscence of proof of special damages when a plaintiff proves slander in one of these four cateogories. }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the basics of copyright law that could affect FanFic?},
 answer:   %{<p>Copyright is a limited monopoly provided by the laws of the United States (title 17, US Code; see the &quot;Copyright&quot; section) to the authors of &quot;original works of authorship,&quot; including literary, dramatic, musical, artistic, and certain other intellectual works. This protection is available to both published and unpublished works. The 1976 Copyright Act generally gives the owner of copyright the exclusive right to do and to authorize others to do the following: </p>

<ol start=1 type=1>
 <li >copy (reproduce) the work; </li>
 <li >distribute the work; </li>
 <li >perform or display the work; and/or</li>
 <li >prepare new (derivative) works based upon the work. A sequel to a movie, Rocky IX for example, is a      derivative work. </li>
</ol>

<p><b>When is a work copyright protected? </b></p>

<p>A work must meet a number of requirements in order to receive copyright protection. First, all works are required to be &quot;original&quot; and &quot;fixed in a tangible form.&quot; The originality requirement is low and it is normally met as long as the work is not a copy of another work. This means that if I come up with some character that resembles Superman without ever having seen or heard of Superman, then my creation is treated as original. </p>

<p>Copyright protection for an original work is instantaneously or automatically secured when the work is first fixed in a tangible form. For instance, if I perform a Klingon death wail in a local park, my performance is not copyrighted since it is not fixed in a tangible form. Someone else may come along and do the same thing the next day. However, if I film the performance, then the film is copyrighted. </p>

<p>Remember that ideas, facts and concepts are not copyrightable (since they are either not original or not fixed). A work might also be in the public domain if it was published before 1909 and the copyright has lapsed. So characters like Captain Nemo or Dr. Jekyll are in the public domain and are not copyrightable. Contrary to popular belief, one does not have to register her copyrighted work for it to receive copyright protection. In the United States, registration is only required for bringing a copyright suit.</p>

<p>A work must also fit under one of several categories such as literary, musical and dramatic works in order to receive protection. These categories are extremely broad so practically all works can fit under some category. For example, computer programs and may be registered as &quot;literary works&quot; and maps and architectural plans may be registered as &quot;pictorial, graphic, and sculptural works.&quot; </p>

<p><b>What rights do copyright owners have?</b></p>

<p>As mentioned above, copyright owners have the exclusive rights to reproduce, distribute, perform or display their works and also to prepare derivative works. These rights, however, only extend to the protected expression (protected expression refers to expression that is original and fixed, as mentioned above). So a well-developed original character, like Scarlett O'Hara, is copyright protected, but a common story line, boy meets girl, is not. </p>

<p>For derivative works, protection only extends to new material. For example, imagine that a screenwriter creates a new adventure involving the Zeus, the Greek mythological god. The copyright of this movie might extend to the new plot and any new characters introduced (including new features of Zeus) but Zeus, as ancient mythology, is in the public domain and the screenwriter or her assignee cannot prevent another author from also using Zeus. </p>

<p><b>Who owns the copyright?</b></p>

<p>If the work is protected, then it becomes important to know who owns the copyright. A copyright can be owned by one author (the original author) or by several authors when the work is a joint work. If the work is a joint work, then all authors are co-owners and are treated like tenants in common, each having an independent right to use or grant a &quot;non-exclusive&quot; license. A corporation can also own works produced by its employees as &quot;works for hire,&quot; or have creators assign copyrights to it. Thus, fan fiction authors could be dealing with individual authors such as Anne Rice or large corporations such as Fox or Viacom. </p>

<p>Now that many fan fiction authors publish on the Internet, copyright holders (regardless of whether they are individual authors or corporations) can easily use search engines to discover their characters being used in unauthorized or unapproved ways. Many owners have tried to stop that use, and as a result, fan fiction authors have received letters telling them to take their stories off-line (See cease and desist letters). </p>

<p><b>Is there an infringement?</b></p>

<p>Even if there is a valid copyright, there is still the question of whether that copyright was infringed.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the basics of trademark law that could affect FanFic?},
 answer:   %{<p>Any word, name, symbol or device which is used (or intended to be used), to identify specific goods and to distinguish those goods from items sold by others and which indicates the source of the goods is eligible for trademark protection. A fan fiction author who writes a new action novel involving Star Wars characters with "Star Wars" in the title could be liable for trademark violation since "Star Wars" is a mark owned and registered by LucasFilm Ltd.</p>

<p><b>Is the mark protected?</b></p>

<p>A mark must be "distinctive" in order to receive legal protection. Many marks are "fanciful".  These marks, like "Xena" or "Hobbit" are inherently distinctive. Other descriptive marks like "Greyhound" may indicate a generic thing, the breed of dog, or a specific company, Greyhound Bus Lines.  To receive protection, the trademark holder must show that an otherwise generic word, Greyhound or Apple, has acquired a secondary meaning in the eyes of the relevant purchasing public. </p>

<p><b>Who owns the mark?</b></p>

<p>A party claiming ownership of the mark must be the first user of the mark in trade, and then continue to use it thereafter. To use the mark in trade is to use it in way (often "affixing the mark to the good or service) that allows consumers to rely on it to identify and distinguish the good or service. Further, a mark must also be "used in interstate commerce" in order for it to receive federal protection (as opposed to common law or state protection). This requirement is usually easy to meet - shipping goods across (or even within) state lines will often satisfy. For example, Mickey Mouse as a trademark satisfies this requirement since it has been used across the country. </p>

<p><b>What rights do trademark holders have?</b></p>

<p>A trademark owner has the right to use exclusively, or to license the name or likeness of his character to avoid customer confusion and to prevent others from profiting off of the owner's intellectual property. For example, you can't market "Star Wars ray guns", because LucasFilm owns the right to that name, and customers may be confused into thinking that your ray gun is sponsored or produced by LucasFilm. </p>

<p>This right is usually geographically limited to first user's area of use plus an amorphous area of expansion. A second user can often use the same mark in a different area with "good faith" (i.e., if the second user didn't know of the first use). Good faith and notice is very hard to prove. The rules change somewhat when a mark receives federal protection. With federal registration, there is "constructive notice of use," meaning a second user is presumed to know of the first user. But if it is the second user who registers the mark and receives federal protection, then the first user is allowed to use the mark in its limited area only.</p>

<p><b>When is there a trademark infringement? </b></p>

<p>The primary question in a case of alleged trademark infringement is whether there is a likelihood of confusion (not actual confusion) for customers. Some factors considered when answering this question include: similarity of appearance between the marks; similarity of sound; similarity of meaning; similarity of purchasers; similarity of marketing channels; sophistication of purchasers; evidence of actual confusion; manner of presenting the mark; strength of the mark; and similarity of products. </p>

<p>There is another type of infringement, too, called trademark dilution. Under this doctrine, the owner of a famous mark is entitled to stop you from commercial use of a mark or trade name, if that use begins after the famous mark has become famous and harms its distinctive quality. Walt Disney has used this concept to stop pornographers from using Snow White or Sleeping Beauty in their films. Fan fiction authors who distribute their work commercially may be accused of trademark dilution in addition to other intellectual property violations.</p>

<p><b>Is there a defense against infringement? </b></p>

<p>Like copyrights, there are some defenses available to counter a trademark infringement. For example, a trademark action will not stop an author's deliberate parody of the mark. Also, a mark is no longer valid if it becomes generic or is abandoned. There is also a limited fair use defense under trademarks. 

<p><b>What happens if I'm found to have infringed? </b></p>

If no defense is allowed, then injunctions and monetary damages are available against the infringer. Also, if "willful violation" is found, then treble damages might also
be awarded. </p>}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an ISP or the host of the message board or chat room be held liable for defamatory of libelous statements made by others on the message board?},
 answer:   %{No.  Under <a HREF="http://www4.law.cornell.edu/uscode/47/230.html#230.c_1">47 U.S.C. sec. 230(c)(1)</a>: "No provider or user of an interactive computer service shall be treated as the publisher or speaker of any information provided by another information content provider."  This provision has been uniformly interpreted by the Courts to provide complete protection
against defamation or libel claims made against an ISP, message board or chat room where the statements are made by third parties.  Note that this immunity does not extend to claims made under intellectual property laws.}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{Can my ISP or the host of a message board be held liable for defamatory statements I make on the grounds that they are a "publisher" or "republisher" of the information?},
 answer:   %{No.  Federal law provides: "No provider or user of an interactive computer service shall be treated as the publisher or speaker of any information provided by another information content provider."  This has been interpreted to protect hosts of discussions between other people against defamation and libel claims as a "republisher" of the information.  Note that this protection does not extend to claims under intellectual property laws.  }
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the benefits of federal trademark registration? },
 answer:   %{Federal registration of a trademark has several advantages including notice to the public of the registrant's claim of ownership of the mark, a legal presumption of ownership nationwide, and the exclusive right to use the mark on or in connection with the goods or services set forth in the registration. 

Registration Provides the Following:
1. Constructive notice nationwide of the trademark owner's claim. 
2. Evidence of ownership of the trademark. 
3. Jurisdiction of federal courts may be invoked. 
4. Registration can be used as a basis for obtaining registration in foreign countries. 
5. Registration may be filed with U.S. Customs Service to prevent importation of infringing foreign goods. 


}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Must an ISP or message board host delete postings that someone tells him/her are defamatory? Can the ISP or message board delete postings in response to a request from a third party? },
 answer:   %{<a href="http://www4.law.cornell.edu/uscode/47/230.html#230.c_1">47 U.S.C. sec. 230</a> gives most ISPs and message board hosts the discretion to keep postings or delete them, whichever they prefer, in response to claims by others that a posting is defamatory or libelous. Most ISPs and message board hosts also post terms of service that give them the right to delete or not delete messages as they see fit and such terms have generally been held to be enforceable under law. }
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{Can my copies infringe a copyright holder's right to distribute?},
 answer:   %{Copyright law gives an author the exclusive right to distribute to the public by sale or other transfer of ownership. This means that if a fan of Superman digitally scans images of Superman from comic books and makes them available on the Internet, then this activity could be a violation of the right to distribute (regardless of whether it was for- or not-for-profit). (Note that if a fan purchases a copy of a Superman comic book legitimately, then the fan is free to sell or transfer that specific comic book without getting the prior consent of the copyright holder; this is called the "doctrine of first sale").

In defense, our fan who copied the Superman images could argue that the copy constitutes fair use. In this argument, "if" and "how" the fan distributes the copied images could affect the outcome of the fair use defense. For example, for-profit marketing activities, as opposed to not-for-profit uses, by the fan often has an adverse affect on fair use.}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What does a request to "cease and desist" mean?},
 answer:   %{A request to cease and desist is basically asking the party to immediately stop the infriging behavior and then permanently refrain from it.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a cease and desist letter recipient have a duty to remove materials alleged to infringe copyright?},
 answer:   %{The cease and desist letter gives its recipient ("you") notice that someone is claiming something you've done or something on your site infringes a copyright.  If the materials that are the subject of the notice are in fact infringing, then you do have a duty to remove them, although there may be statutory provisions (<!--GET FAQLink 14-->) that protect you from a lawsuit if the materials were posted by someone else.  You may have to give the poster notice of the complaint.

If you do not believe that the materials are infringing, or if you believe that you are making fair use of the materials, you may choose to take the risk of not removing the materials, but a lawsuit might follow in which the complainer tries to prove they they are right and you are wrong.  If the accuser obtains a court order, then you must take down the materials.}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the legal definition of defamation?},
 answer:   %{The elements that must be proved to establish defamation are: (1) A publication to one other than the person defamed; (2) of a false statement of fact; (3) which is understood as being of and concerning the plaintiff; and (4) which is understood in such a way as to tend to harm the reputation of plaintiff. }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is false light invasion of privacy?},
 answer:   %{"False light" is a claim that publicity invades a person's (plaintiff's) privacy by a false statement or representation that "places the plaintiff in a false light that would be highly offensive to a reasonable person."}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between false light invasion of privacy and defamation?},
 answer:   %{The distinction between the two is a subtle one.  The false light cause of action focuses upon indignity and defamation focuses upon reputation.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{Does it make any difference if I am commenting on a product or company rather than a person?},
 answer:   %{Product disparagement law prohibits certain false claims about another's goods or services.  While a defamatory statement harms the reputation and character of a person or corporation, a product disparaging statement harms the marketability of the goods being disparaged.  Product disparagement is typically harder to prove.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{How does the First Amendment to the Constitution affect defamation?},
 answer:   %{The free speech guarantees under the Constitution protect certain speech and commentary.  The degree of protection generally depends on whether the person commented about is a private or public figure and whether the statement is regarding a private or public matter.  According to the <i>New York Times</i> rule (from the case <a href="http://caselaw.lp.findlaw.com/scripts/getcase.pl?court=US&vol=376&invol=254">New York Times v. Sullivan</a>), when the plaintiff is a public figure and the matter is one of public concern, the plaintiff must prove "malice" or "reckless disregard" on the part of the defendant.  If both parties are private individuals, there is less protection for the speech because the plaintiff only needs to prove negligence. }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between libel and slander?},
 answer:   %{Libel is a defamatory statement expressed in a fixed medium such as a writing, picture, sign or electronic broadcast.  Slander is a defamatory statement expressed in a transitory form such as speech.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{My host wants to remove my material just because some trademark owner complained.  Is that legal?},
 answer:   %{The answer depends on the terms of your agreement with your host.  If you agreed to allow them to do it, then they can. If you didn't read the fine legal print, that's considered your problem, not theirs. Some hosts may require complaining mark owners to substantiate their rights by submitting copies of trademark registrations.  Others may not ask for proof to back up the complaint.

The reality is that your host is also liable if your material infringes a trademark, so they can face court claims also.  This is because the host is considered a contributory infringer because it circulates the infringing material further and benefits by collecting money from you. 

Very few hosts can or will pay the costs of defending themselves in court.  It's much easier to simply delete the allegedly infringing material.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a trade secret?},
 answer:   %{A trade secret is business information that is the subject of reasonable efforts to preserve confidentiality and has value because it is not generally known in the trade.  Such confidential information will be protected against those who obtain access through improper methods or by breach of confidence.  Infringement on a trade secret is a tort and a type of unfair competition.  Every alleged infringement of a trade secret involves two main issues: (1) whether there is valuable and secret business information; and (2) whether this defendant used improper means to obtain that information.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a preliminary injunction?},
 answer:   %{An order by the court requiring the defendant to do or refrain from doing some action pending a full trial on the merits of the lawsuit.  Sometimes in intellectual property litigation, the property owner, soon after filing the complaint, will make a motion for a preliminary injunction requiring the defendant to stop doing those things the plaintiff alleges are infringing the plaintiff's intellectual property rights.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the factors the court considers in issuing a preliminary injunction?},
 answer:   %{Traditionally, a party seeking a preliminary injunction is required to show five basic factors: (1) that there is a probability of success at the ultimate trial on the merits of the claim; (2) that the plaintiff will undergo "irreparale injury" pending a full trial on the merits; (3) that a preliminary injunction will preserve the status quo which preceded the dispute; (4) that the hardships favor the plaintiff; and (5)that a preliminary injunction will favor the public interest and protect third parties.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "common law" rights in a trademark?},
 answer:   %{Common law rights are those that are recognized by courts as a matter of traditional equitable principles and fairness, even when there is no statute or other law that has been enacted by the legislative branch of government to cover the situation. It also arises from the leeway that judges have in interpretating the language of the written laws when the meaning is not clear.  Common law is often known as "judge-made" law. Common law is learned by reading the actual decisions made by courts.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is libel?},
 answer:   %{Libel is a defamatory statement expressed in a fixed medium, usually writing but also a picture, sign, or electronic broadcast.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{Who is bound by the First Amendment?},
 answer:   %{The rights in the First Amendment apply against the federal government, state governments (through the Fourteenth Amendment), and "state actors," such as government officials and institutions controlled by the state.  State schools, in particular, are state actors bound by the First Amendment.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is disparagement?},
 answer:   %{As defined in Black's Law Dictionary (7th ed. 1999), disparagement is "A false and injurious statement that discredits or detracts from the reputation of another's property, product, or business.  To recover in tort for disparagement, the plaintiff must prove that the statement caused a third party to take some action resulting in specific pecuniary loss to the plaintiff." }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a summary judgment?},
 answer:   %{A procedure that permits a judgment to be granted to all or part of a case if there is no real dispute in the evidence that would require a trial to determine the facts.  The judgment is often prompt and direct. }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is contributory trademark infringement?},
 answer:   %{Even if you are not using someone's mark directly in a product or service you sell, your opponent may say you have liability under the theory of "contributory trademark infringement." This liability may exist if you knowingly allow someone else to violate another party's trademark rights and personally gain from such violation.  It may also exist if you intentionally encourage another person to violate a trademark.

For example, in one case a court found that the operator of a California swap meet was liable for contributory trademark infringement because it was aware that vendors at its swap meet were selling counterfeit recordings that violated the trademark of the company that owned the rights to the recordings.  While the swap meet operator did not sell the counterfeit items itself, it profited on the sale of the items by selling booth space to the vendors and collecting an entrance fee from the customers buying the infringing products.   In another case the manufacturer of a generic drug was found liable for contributory trademark infringement because it continued to supply the drug to pharmacists it knew were mislabeling the drug with the name of the trademarked medication.

However in another case a court felt that a company providing domain name registration, had less control over the use of its service and was not liable for contributory trademark infringement when someone registered a domain name that infringed a trademark.

The important issues in determining liability for contributory trademark infringement are if you are aware of the infringement, if you have the ability to monitor and control the use of your product or service, and you are in a position to receive some benefit from the violation. 
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a trade secret?},
 answer:   %{A trade secret is business information that is the subject of reasonable efforts to preserve confidentiality and has value because it is not generally known in the trade.  Such confidential information will be protected against those who obtain access through improper methods or by breach of confidence.  Infringement on a trade secret is a tort and a type of unfair competition.  Every alleged infringement of a trade secret involves two main issues: (1) whether there is valuable and secret business information; and (2) whether this defendant used improper means to obtain that information.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{When is a company deemed "publically traded"?},
 answer:   %{A publically traded company is one which trades stock on any of the stock exchanges such as the NASDAQ or New York Stock Exchange.  Any member of the public can buy and sell shares of the company stock.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "Exemplary Damages"?},
 answer:   %{Exemplary damages are punitive damages, which are defined as "Damages awarded in addition to actual damages when the defendant acted with recklessness, malice, or deceit."  Punitive damages are intended to punish and thereby deter blameworthy conduct. The Supreme Court has held that three guidelines help determine whether a punitive-damages award violates constitutional due process: (1) the reprehensibility of the conduct being punished; (2) the reasonableness of the relationship between the harm and the award; and (3) the difference between the award and the civil penalties authorized in comparable cases. BMW of North America, Inc. v. Gore, 517 U.S. 559, 116 S.Ct. 1589 (1996)."}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "Permanent Injunction"?},
 answer:   %{An injunction is "A court order commanding or preventing an action. * To get an injunction, the complainant must show that there is no plain, adequate, and complete remedy at law and that an irreparable injury will result unless the relief is granted... [A]permanent injunction [is] [a]n injunction granted after a final hearing on the merits. * Despite its name, a permanent injunction does not necessarily last forever."}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the possible penalties for copyright infringement?},
 answer:   %{Under the Copyright Act, <a href="http://www4.law.cornell.edu/uscode/17/ch5.html" target="new">penalties for copyright infringement</a> can include:
<ol class="main"><li class="main">an injunction against further infringement -- such as an order preventing the infringer from future copying or distribution of the copyrighted works
<li class="main">impounding or destruction of infringing copies
<li class="main"><a href="http://www4.law.cornell.edu/uscode/17/504.html" target="new">damages</a> -- either actual damages and the infringer's profits, or statutory damages 
<li class="main">costs and attorney's fees
</ol>
<p>A copyright owner can only sue for infringement on a work whose copyright was registered with the Copyright Office, and can get statutory damages and attorney's fees only if the copyright registration was filed before infringement or within three months of first publication.  (<a href="http://www4.law.cornell.edu/uscode/17/411.html" target="new">17 U.S.C. 411</a> and <a href="http://www4.law.cornell.edu/uscode/17/412.html" target="new">412</a>)}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I find out whether a work has a registered copyright?},
 answer:   %{Works are copyrighted as soon as they are "fixed in a tangible medium of expression," but some legal rights and remedies are available only if the work's copyright is registered.  To find a copyright registration, you may <a href="http://www.copyright.gov/records/" target="new">search copyright records at the Copyright Office website</a>, but be aware that not finding a match does not mean the work is uncopyrighted.  }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the limits on dilution?},
 answer:   %{The Federal Trademark Dilution Act of 1995 (FTDA, <a href="http://www4.law.cornell.edu/uscode/15/1125.html">15 U.S.C. 1125</a>) prohibits the commercial use of a famous mark if such use causes dilution of the distinctive quality of the mark.

A mark may be diluted either by "tarnishment" or "blurring."  Tarnishment occurs when someone uses a mark on inferior or unwholesome goods or services. For example a court found that a sexually explicit web site using the domain name "candyland.com" diluted by <a href="http://www.cyberlaw.com/cylw0296.html">tarnishment</a> the famous trademark "CANDY LAND" owned by Hasbro, Inc. for its board games.

Blurring occurs when a famous mark or a mark similar to it is used without permission on other goods and services.  The unique and distinctive character of the famous mark to identify one source is weakened by the additional use even though it may not cause confusion to the consumer.

The following uses of a famous mark are specifically permitted under the Act:

1) Fair use in comparative advertising to identify the goods or services of the owner of the mark.
2) Noncommercial uses of a mark.
3) All forms of news reporting and news commentary.

In addition, the <a href="http://infoeagle.bc.edu/bc_org/avp/law/lwsch/journals/bclawr/42_1/05_FMS.htm">courts have differed</a> as to what constitutes a "famous" mark under the FTDA.  In some cases the courts have said that the famousness requirement limits the Act to a very small number of very widely known marks.  Other courts, however, have accepted lesser-known marks as PANAVISION, WAWA and EBONY as being famous and yet others have said that merely being famous in one's product line is sufficient.

Many states also have antidilution laws protecting mark owners.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What does "Secondary Meaning" refer to?},
 answer:   %{Many words are commonly used in ordinary language.  Can they become trademarks?  They can if they acquire special significance in reference to particular goods.  For example, "apple" is a common word, but also a trademark for computers and for recordings.  The word has acquired "secondary meaning" in each product category because consumers associate it with a particular brand of product.

Secondary meaning gives trademark owners protection, but does not prevent people from using the same word for other types of products or in common conversation.

}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "injunctive relief"?},
 answer:   %{"Injunctive relief" (or injunction) refers to a court order that someone do or stop doing something.  A preliminary injunction is an order before a full trial, "to preserve the status quo," while a permanent injunction may be ordered after trial to protect the complainant's rights.  

Normally, when one party sues another for trademark, patent, or copyright infringement, the parties can either settle the matter out of court or go to a civil trial.  Meanwhile both parties may continue their business until either event occurs. 

However, if the owner of a trademark, patent, or copyright can show a court that the violation of its rights is obvious, that it is likely to prevail in a trial, and that it is being harmed by the continued violation of rights while it awaits trial, the court may order a preliminary injunction directing the other party to stop selling the infringing product or to cease operating an infringing web site immediately until the matter is settled.  Failure to respond to a court-ordered  injunction may result in criminal penalties for contempt, such as a fine or imprisonment.
}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is intellectual property?},
 answer:   %{Intellectual property consists of property created through human creativity.  It includes, for example, literature, the visual arts, music, drama, compilations of useful information, computer programs, biotechnology, electronics, mechanics, chemistry, product design, and trade identity symbols.  Intellectual property law is designed to promote human creativity without excessively restricting dissemination of the fruits of such creativity.  Intellectual property rights are embodied in patents, trade secrets, copyrights, and trademarks.
}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a patent?},
 answer:   %{A patent is a form of intellectual property.  A U.S. patent is a right granted by the United States Patent and Trademark Office to an inventor to exclude others from making, using, selling, offering for sale, or importing an invention for a limited time.  In the U.S.,  Patent law is driven by the language of the Patent Act, 35 U.S.C. }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What can be patented?  },
 answer:   %{[not yet answered]}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What may not be patented?},
 answer:   %{The following subjects are not entitled to patent protection:

}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the purpose behind the patent law?  },
 answer:   %{The origin of U.S. patent law can be found in the United States Constitution, Article I, Section 8, Clause 8, which provides that:  "Congress shall have the power }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{If abstract ideas and mental processes cannot be patented, how can software based on a mathematical algorithm receive patent protection?},
 answer:   %{For years, software was considered outside the scope of patent protection to the extent based on mathematical algorithms, as mathematics is the basic working tool of contemporary science and technology and algorithms can be natural laws.  In 1981, the Supreme Court held that software-related inventions are not per se to be excluded from patent protection simply because the process of performing the program's function may involve underlying mathematical algorithms.  Software uses a non-physical process by operating electronically through the utilization of a mathematical equation (algorithm) to control the output of the computer program.  Mathematical algorithms have a functional application in computer programs, and thus can be protected under the Patent Act.  To use an example from physics, electricity was not patentable, but the way in which electricity transmits information may be patentable.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is an "algorithm"?},
 answer:   %{An algorithm is the same as a mathematical equation in its structure, but it becomes a function through its input and output.  For example, the equation (a+b = c) is a simple math equation.  However, if we take that equation and add values for the letters such as, a=1, b=2, c=3, and then the program starts on a computer, this equation has created a function for simple letters and a summation.  When a machine uses an equation to guide its operation, this is called an algorithm and the software for doing this can potentially be patented.  If the formula is related to a natural law (such as E=mc^2), it cannot be patented as such, much the same as a simple math equation.  However, such natural laws can be used to make patentable inventions in the categories discussed above, including software.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the requirements for patent protection?},
 answer:   %{To qualify for patent protection, an invention must be new, useful and non-obvious.  

}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What happens if an invention is made public before a patent application is filed?},
 answer:   %{In the United States, an inventor cannot patent an invention if he or she discloses it to the public more than one year before filing for patent protection.  This is sometimes known as the "on sale" bar to patentability.  Public disclosure can occur when the invention is described in any published writing, or when the invention is offered for sale, including any pre-manufacture discussion about the invention that involves describing it.  In most foreign countries, there is no one year grace period; the inventor must file the patent application before the invention is publicly offered for sale, used or displayed.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "prior art"?},
 answer:   %{Publicly disclosed inventions, including patented inventions, are known as "prior art" that can be cited against a new patent applicant.  Publicly disclosed inventions are considered prior art without regard to where (United States, Europe, Asia, etc.) or in what form the public disclosure occurred (a journal article, an archived PhD dissertation, an online publication).  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What happens if prior art is not disclosed in a patent application?},
 answer:   %{If a patent applicant intentionally fails to disclose relevant preexisting technology of which he or she was aware in his application, the patent could be invalidated on the grounds that the applicant engaged in inequitable conduct.  Intentional failure to disclose can be inferred from evidence that the patent applicant was aware of the undisclosed technology and knew that it was material.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What are patent "claims"?},
 answer:   %{A patent consists of an abstract, a description of the invention, disclosures of prior art, drawings, and one or more claims.  The claims are the only truly enforceable part of a utility patent, and they define the property right owned by the patent holder.  They are written in technical language, and must embody subject matter that is within the scope of patent law, is novel and is not obvious.  The more broadly written the claims, the less likely they are to avoid rejection or invalidation on the grounds of obviousness or anticipation by prior technology.  The more narrowly written, the less likely a competing technology or device infringes the claims.  To infringe a patent, one must practice every element of a claim.  If you do not practice one or more of the elements of a claim, then you do not infringe that claim.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the elements of a claim?},
 answer:   %{Patent claims generally contain an introductory paragraph called a "preamble," which is followed by a series of phrases called "elements."  Elements can be recited as a means or steps for performing a specified function, but elements recited in this way may be interpreted more narrowly than if recited by name, structure or as a defined step.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a claim's "priority date"?},
 answer:   %{A claim's priority date is the date upon which the technical disclosure that fully describes the invention covered by that claim is first filed with some patent office somewhere in the world.  A patent must state on its face any such claim of priority.  The claim must define the invention over any prior art available to the public before the priority date.  If prior art is published after the priority date, the publication does not invalidate the claim.  If it is published less than a year before the priority date, it may invalidate the claim unless the inventor can prove invention prior to the publication date.  Finally, if a publication date is more than one year prior to a claim's priority date, then the publication invalidates the claim.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a claim's invention date?},
 answer:   %{Making an invention requires a conception and a reduction to practice. The invention date is normally the date upon which an inventor first conceives his or her invention as defined by a given claim - the "conception date."  The inventor must demonstrate diligence in reducing the invention to practice in order to preserve the conception date as the date of invention.  Reducing the invention to practice means building a working example of the invention or filing a patent application that has an adequate disclosure of the invention. Sometimes under U.S. law, prior art must predate the invention date in order to invalidate the claim.  In all other countries outside the U.S., the invention date has no significance; only the "priority date" is used to determine whether prior art invalidates a claim.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "provisional" patent application?},
 answer:   %{A provisional patent application is not examined, it does not have to include any claims defining the invention precisely, it does not have to name the inventors or provide their citizenship, and it expires in one year.  The purpose of a provisional patent application is to establish a filing date for the invention disclosure that may later be claimed as a "priority" date in a later-filed regular or foreign patent application.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{How long is a patent's term?},
 answer:   %{For patents filed on June 8, 1995 or later, the protection lasts for 20 years from the date the patent application is filed.  For patents filed prior to June 8, 1995, the term is 17 years from the date of issuance or 20 years from the date of application, whichever is longer.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean to "infringe" a patent?},
 answer:   %{If you are accused of patent infringement, you are accused of having made, sold or offered for sale an invention described in one of the claims of a valid patent, without the patent owner's authorization.  To determine if infringement has occurred, a court will look at the patent's claims, interpret them, and compare them to your device, process, method etc.  Infringement occurs if your accused item performs each of the elements of any of the claims.  Note that you may be liable for inducing infringement or contributing to infringement, even if you did not directly infringe a patent, if you encourage or assist someone else to infringe a patent.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the defenses to patent infringement?},
 answer:   %{There are two basic lines of defense: non-infringement and invalidity.

<b>Non-infringement</b>: To infringe a patent, one must practice every element of a claim.  If you do not practice one or more of the elements of a claim, then you do not infringe that claim.  This determination often rests on how a court interprets the language of the claims you are accused of infringing.  

<b>Invalidity</b>: Only a valid patent can be enforced.  Issued patents are presumed valid, but this presumption can be overcome if prior art exists that demonstrates an invention was not novel or that it was obvious at the time the patent application was filed.  Especially in the case of software and Internet business method patents, articles disclosing or describing the patented inventions may exist in trade publications that would not have been found by the patent examiner and would not have been part of the prosecution file of an issued patent on file with the USPTO.  The patent holder's failure to name all inventors may also invalidate a patent.
}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the consequences of being found to have committed patent infringement?},
 answer:   %{A patent owner may recover money damages in the form of a "reasonable royalty," which is the amount the patent holder could have earned in licensing the patented technology.  Under certain circumstances, the patent owner may recover lost profits as an alternative measure of damages. The money damages amount may be tripled if the infringement is found to be "willful."  The patent owner may also be entitled to enjoin further use and sale of the patented invention.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Does it matter if infringement is accidental or innocent?},
 answer:   %{It does not matter for liability purposes that a patented infringer was unaware of the patented technology when infringement occurred.  However, willful or intentional infringement may carry a higher monetary penalty than innocent infringement.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{How does copyright protection differ from patent protection?},
 answer:   %{A copyright can protect the particular way in which ideas are expressed in a particular computer program.  A copyright owner has the right to prevent others from making unauthorized, literal copies of a software program, but not from independently creating software that performs the same functions.  

A patent, on the other hand, grants an inventor exclusive rights in the technology.  With a software patent, one may prevent others from making, using or selling a program that performs the same process or function as the patented technology, even if different code is used.  Often, a software developer does not merely wish to rely on the prevention of verbatim copying of the software, since a competitor may observe the functions performed by the software, and without knowing the details of the software code underlying the functions, write equivalent code.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Can computer software be protected by copyright?},
 answer:   %{Yes.  Software copyright law is a recent branch of the 1976 Copyright Act that was intended to protect artistic creations and creativity.  Initially there was a question of whether copyright law could protect software because computer programs contain functional instructions regarding what a computer should do if given a command.  Strictly functional instructions and ideas are not copyrightable because they do not meet the minimal copyright requirement for creativity.  The existence of a requisite level of creativity was questioned in software.  During the 1980s, however, through court decisions and congressional guidance, copyright law became a major form of legal protection for computer programs, some databases, and software technology.  Through copyright protection, creators of computer programs can prevent or seek damages for unauthorized copying of programs.  This right is not absolute, however.  Courts still question whether particular elements of computer programs are sufficiently expressive to be protectable under copyright law.  For example, some courts have held that a software program's graphical user interface (GUI) (or at least some elements of it) is insufficiently expressive for copyright protection.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Can software technology be protected by patent law?},
 answer:   %{Yes.  Software technology development is highly incremental in nature and, as a result, truly unique designs, methods or approaches are rare.  In addition, prior art with respect to software technology is not centralized or even easily discovered.  However, patents can and do often issue on software-based technology that is not, in fact, novel.  Computer technologies can be patented as processes (software), machines, even articles of manufacture (the CD containing the software, for example).  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Can the same software qualify for both copyright and patent protection?},
 answer:   %{Yes.  Software may qualify for both copyright and patent protection provided, of course, that the software satisfies the requirements for those intellectual property rights.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a business method patent?},
 answer:   %{A business method patent is a specific type of software patent on a computer implemented way of transacting business. As in the case of other software patents, business method patents can have process claims in the form of a sequence of steps comprising the business method carried out using a computer system, the system configuration defined by the software for carrying out the business method, or an article of manufacture, such as a CD having the software for carrying out the business method stored on it. Some business method patents are controversial because they appear to cover otherwise conventional business techniques, such as auctions, when implemented on the Internet or other networked computers. Other business method patents have been allowed without considering the best prior art and may be overbroad.

Patents have issued on methods and systems covering -- or purporting to cover -- such things as:  all Internet-like browser/display systems (to Prodigy Services Company); reverse auctions over the Internet (to E-Bay); placing a purchase order via a communications network (the "one-click" patent to Amazon.com), and the like.  Many computer program and so-called "business method" patents have been challenged as invalid and improvidently granted on the grounds that the innovation lacks sufficient uniqueness or inventiveness.  Nonetheless, because a patent can confer broad and powerful rights upon its owner, and once issued is presumptively valid, patent owners are attempting to enforce their rights against rival software developers or website operators.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Where I can read more about business method patents?},
 answer:   %{The U.S. Patent Office has a great deal of useful information on its website, at <a href="http://www.uspto.gov/web/menu/pbmethod/" target="new">http://www.uspto.gov/web/menu/pbmethod/</a>.
}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I search for a U.S. Patent?},
 answer:   %{Issued U.S. patents can be found on the United States Patent and Trademark Office website, at http://www.uspto.gov/patft/index.html.  They are also available at patent depository libraries around the country.  For more information on libraries, see http://www.uspto.gov/go/ptdl/.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I cut photographs out of a book, frame them, and sell them separately as },
 answer:   %{.Probably not.&nbsp; In essence, what you would be doing is creating
a new work based on preexisting copyrighted material}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find U.S. patent law?},
 answer:   %{The Patent Act is codified at <a href="http://www4.law.cornell.edu/uscode/35/pII.html" target="new">35 U.S.C. 100 and following</a>.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find U.S. patent law?},
 answer:   %{The Patent Act is codified at <a href="http://www4.law.cornell.edu/uscode/35/pII.html" target="new">35 U.S.C. 100 and following</a>, available from <a href="http://www4.law.cornell.edu/uscode/35/pII.html" target="new">http://www4.law.cornell.edu/uscode/35/pII.html</a>.  }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I take photographs I},
 answer:   %{.Yes.}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{What if I buy a digital photo, print it out, and put that on a tile
or t-shirt?},
 answer:   %{.The courts have not addressed this specific issue, but digital photos
sold individually could be seen as }
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{Is a link to a web page a derivative work?},
 answer:   %{.Probably not, but the law on linking isn}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I take a character from Shakespeare and use it in a very different
context?},
 answer:   %{.Yes.&nbsp; Shakespeare}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{.I have created a new play based on Shakespeare&#8217;s play, <i>Hamlet</i>.},
 answer:   %{.For your play to be a derivative work, you must make some minimally
creative changes, but the standard for &#8220;creativity&#8221; is pretty low.}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{.Can I take a character from a movie, like Chewbacca from <i>Star
Wars</i>, and use it in a play with a very different plot and otherwise
different characters?},
 answer:   %{.Probably not.? The people who hold copyright in <i>Star Wars</i>
own the characters as well as the plot, the filmed images, etc.  Placing
a distinctive fictional character in a different context or medium is still
copying that character, and therefore infringement.   However,
if you use the character for the purposes of parody or criticism you might
be making a legitimate fair use of the character.  Note that in one
case involving Walt Disney, Inc. and a comic book publisher, the comic
book publisher argued that his use of the images of Mickey Mouse, Minnie
Mouse and Donald Duck was satirical, and therefore fair use.  The
Ninth Circuit rejected the fair use argument, reasoning that the comic
book took more of the images than was necessary to suggest the characters
in the minds of the readers and therefore exceed the bounds of fair use. 
<i>See Walt Disney Productions v. Air Pirates</i>, 581 F. 2d 751 (9th Cir.
1978).}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I make a sculpture based on a photograph without permission?},
 answer:   %{.No. The sculpture would be a derivative work.&nbsp; In one famous case,
artists Jeff Koons made a sculpture based on a photograph of a group of
puppies and argued that the sculpture was a }
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I take a photograph of a painting and sell the photograph?},
 answer:   %{.Probably not.&nbsp; If the photograph contained a sufficient amount
of creativity, it would be a derivative work; if not, it would simply be
a copy.&nbsp; Either way, you need permission unless you can show your
use is fair use.&nbsp; Fair use may be especially difficult to show if
your photograph is essentially a }
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{.I},
 answer:   %{.No.&nbsp; Assuming the original traditional folk song is in the public
domain, both of you are free to copy and revise the original song.&nbsp;
You are not free to copy each other}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{.What if I},
 answer:   %{.You and your partner are joint authors of the article, which means you
are both free to do what you like with it as long as you don}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{.Can I make and sell lithograph prints or T-Shirt with a likeness of a famous
character such as Stan Laurel of <i>Laurel and Hardy</i>?},
 answer:   %{.No, but not because the prints or T-Shirts are derivative works (unless
perhaps they were adapted from a scene or series of scenes from a particular
movie).}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{.I},
 answer:   %{.No. The design itself might be patentable, but it is not copyrightable. 
Copyright law covers only expressions, not ideas.  So we can}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I write a book of trivia questions based on a television show?},
 answer:   %{.Probably not.&nbsp; A court <a href="http://caselaw.lp.findlaw.com/scripts/getcase.pl?court=2nd&navby=case&no=977992">held</a>
that a book of trivia questions based on the television show <i>Seinfeld</i>
was substantially similar to the show itself and therefore could be treated
as a }
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{.I},
 answer:   %{.That depends.&nbsp;&nbsp; Does the second book use the same expression
as used in your book?&nbsp; If so, and that expression is minimally creative,
you may have an action for copyright infringement.&nbsp; If not, the problems
will probably treated as uncopyrightable products of a mathematical, predictable
distribution of the pieces on the board based on principles of play.&nbsp;
In an old case, an author of a book on contract bridge sued a newspaper
for printing a bridge problem that he claimed was substantially similar
to a problem contained in his book.&nbsp; The court held that the author
had }
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean to obtain a license for a patent?},
 answer:   %{A license, in its simplest terms, is a promise by the patent owner (the licensor) not to sue the licensee for exercising one of the patent owner's rights.  Patent laws grant the patent owner rights to exclude others from making, using, or selling the patented invention.  Using a contract called a "license," a patent owner may choose to allow one or more others to make, use and/or sell the invention, usually in exchange for payment.  As long as the licensee abides by the terms of the license contract, a patent owner cannot sue the licensee for infringement.  Patent infringement cases are often settled by the accused infringer entering into a license agreement with the patent owner and promising to pay the patent owner royalties.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Who may own patents? },
 answer:   %{The presumptive owner of an invention is the human inventor(s).  The inventor may transfer ownership to anyone (including a corporation).  Employees often assign the rights to their invention to their employers as part of their employment contracts.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{Are patents assignable?},
 answer:   %{The patent laws provide that patents shall have the attributes of personal property, and as such, can be assigned by a written document.  The inventor, who is initially the presumed owner of the patent rights to the invention, may transfer ownership to anyone, including a corporation.  Employees often assign the rights to their inventions to their employers as part of their employment contracts.}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the "principal register?"},
 answer:   %{The main federal register of marks established by the Lanham Act.  Trademarks, service marks, collective marks and certification marks may be registered on the principal register. 
}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I oppose a trademark registration?},
 answer:   %{[not yet answered]}
)

mapping[%{Documenting Your Domain Defense}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the elements of a defamation claim?},
 answer:   %{.
The party making a defamation claim (plaintiff) must ordinarily prove four elements: 
<ol>
        <li>a publication to one other than the person defamed;</li>
        <li>a false statement of fact; </li>
        <li>that is understood as </li>
        <blockquote>
        a. being of and concerning the plaintiff; and <br>
        b. tending to harm the reputation of plaintiff.
        </blockquote>

        <li>If the plaintiff is a public figure, he or she must also prove actual malice. </li>
</ol>}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Can search engines be liable for copyright infringement by providing hyperlinks to search results?},
 answer:   %{Some Internet search engines have been getting "takedown" requests under the Digital Millennium Copyright Act, Section 512 (see <!--GET FAQLink 14--> for more information).  The DMCA provides a <a href="http://www4.law.cornell.edu/uscode/17/512.html#512.d">safe harbor</a> to information location tools that comply with takedown notices, but it is not settled whether they would be liable for copyright infringement if they did not use the safe harbor.  Arguably, computer-generated pages of links do not materially facilitate infringing activity or put their hosts on notice of copyright infringements.  }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{What's wrong with pornography?},
 answer:   %{Pornography is restricted or forbidden in many jurisdictions.  Unauthorized use of a mark on pornographic material is a classic example of trademark "tarnishment" because it leads viewers to associate the mark with "unsavory" activity. Only famous mark owners are protected against tarnishment under state and federal "anti-dilution" laws, however an association with pornography may also constitute "trade libel" which is a common law offense against non-famous marks as well. }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between copyright and trademark?},
 answer:   %{Copyright protects original expression in literary and artistic works such as plays, books, films, songs, software, performances, etc.).  To qualify for copyright protection, a work must be an original creation of the author and not copied from any other source.  In the U.S., copyright does not protect facts.  Individual words cannot be copyrighted, and there is a gray area of protection for short phrases.  Copyright owners have strong rights to prevent copying of their material, subject to the doctrine of "fair use."   Copyrights arise when the work is fixed in a permanent form.  Infringement consists of copying, publicly distributing, making changes to, or publicly distributing or performing the work without the author's permission. 

Trademark only protects names and logo images that are used to label goods or services.  Trademark does not require originality; its purpose is to identify the source of goods.  In the U.S., trademark rights arise only when there is actual use in commerce.  Infringement consists of selling goods or services under the same or a confusingly similar name.  Trademark has its own types of "fair uses" including use for product comparison and criticism, news reporting, and parody.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "trade dress"?},
 answer:   %{At one time the term referred only to the manner in which a product was dressed up to go to market e.g. a label, package, display card and other packaging that made up the total image.  Today, the term refers to the totality of elements in which a product or service is packaged or presented. These elements combine to create the whole visual image presented to customers.  This "trade dress" is capable of acquiring exclusive legal rights as a type of trademark--or, identifying symbol of origin.  All aspects of appearance are potentially protected as trade dress.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "generic name"?},
 answer:   %{A generic word is one used by much of the public to refer to a class or category of product or service.  A generic name can not be protected or registered as a trademark or service mark. For example, no one seller can have trademark rights in "telephone" or "oven."  If a seller did have exclusive rights to call something by its recognized name, it would amount to a practical monopoly on selling that type of product.  Even established trademarks can lose their protection if they are used generically: thermos and escalator are famous examples.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{ISP as Copyright Cop},
 answer:   %{Notice that this letter comes from an Internet Service Provider (ISP) and not from a copyright owner.  The Digital Millenium Copyright Act both protects ISPs from copyright liability (leaving the end user with that liability) and requires ISPs to participiate in a "takedown" process when copyright owners claim infriging use.  See the FAQs associated with this notice for more information.}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "trade dress"?},
 answer:   %{At one time the term referred only to the manner in which a product was dressed up to go to market e.g. a label, package, display card and other packaging.  Today, the term refers to the totality of elements in which a product or service is packaged or presented.  These elements combine to create the visual image presented to customers.  This "trade dress" is capable of acquiring exclusive legal rights as a type of trademark---or, identifying symbol of origin.  All aspects of appearance are potentially protected as trade dress}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "generic" name?},
 answer:   %{A word used by the majority of the public to name a class or category of product or service.  A generic name cannot be protected or registered as a trademark or service mark.  For example, no seller can have trademark rights in "telephone" or "oven."  If a seller did have exclusive rights to call something by its recognized name, it could amount to a monopoly on selling that type of product. }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What defenses may be available to someone who is sued for defamation?},
 answer:   %{There are ordinarily 6 possible defenses available to a defendant who is sued for libel (published defamatory communication.)
1. Truth.  This is a complete defense, but may be difficult to prove.
2. Fair comment on a matter of public interest.  This defense applies to "opinion" only, as compared to a statement of fact.  The defendant usually needs to prove that the opinion is honestly held and the comments were not motivated by actual "malice." ( Malice means knowledge of falsity or reckless disregard for the truth of falsity of the defamatory statement.)
3. Privilege.  The privilege may be absolute or qualified.  Privilege generally exists where the speaker or writer has a duty to communicate to a specific person or persons on a given occasion.  In some cases the privilege is qualified and may be lost if the publication is unnecessarily wide or made with malice. 
4. Consent.  This is rarely available, as plaintiffs will not ordinarily agree to the publication of statements that they find offensive.
5. Innocent dissemination. In some caes a party who has no knowledge of the content of a defamatory statement may use this defense.  For example, a mailman who delivers a sealed envelope containing a defamatory statement, is not legally liable for any damages that come about from the statement.
6. Plaintiff's poor reputation.  Defendant can mitigate (lessen) damages for a defamatory statement by proving that the plaintiff did not have a good reputation to begin with.  Defendant ordinarily can prove plaintiff's poor reputation by calling witnesses with knowledge of the plaintiff's prior reputation relating to the defamatory content.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the "publication" of a defamatory statement?},
 answer:   %{Publication is the dissemination of the defamatory statement to any person other than the person about whom the statement is written or spoken.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{May someone other than the person who originally made the defamatory statement be legally liable in defamation?},
 answer:   %{One who "publishes" a defamatory statement may be liable.  However, <a href="http://www4.law.cornell.edu/uscode/47/230.html#230.c_1">47 U.S.C. sec. 230</a> says that online service providers are <b>not</b> publishers of content posted by their users.  Section 230 gives most ISPs and message board hosts the discretion to keep postings or delete them, whichever they prefer, in response to claims by others that a posting is defamatory or libelous. Most ISPs and message board hosts also post terms of service that give them the right to delete or not delete messages as they see fit and such terms have generally been held to be enforceable under law. }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is slander?},
 answer:   %{Slander is a defamatory statement expressed in a transitory medium, such as verbal speech.  It is considered a civil injury, as opposed to a criminal offence.  Actual damages must be proven for someone to be held liable for slander.  The tort of slander is often compared with that of libel, which is also characterized as a defamatory statement, but one made in a fixed form, such as writing.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Patent and Trademark Office?},
 answer:   %{The <a href="http://www.uspto.gov/">PTO</a> is a United States government agency affiliated with the Department of Commerce.  Its primary functions processing patent and trademark applications.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is The Official Gazette of the U.S. Patent and Trademark Office?},
 answer:   %{According to the PTO website, the Gazette is the "official journal of the United States Patent and Trademark Office relating to trademarks."  The website further explains that the publication is issued each Tuesday, and includes "an illustration of each trademark published for opposition, an alphabetical list of registered trademarks, a classified list of registered trademarks, an index of registrants, U.S. Patent and Trademark Office notices; a list of canceled trademark registrations, a list of renewed trademark registrations, and a list of Patent and Trademark Depository Libraries (PTDLs)." }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is libel?},
 answer:   %{Libel is a false statement of fact expressed in a fixed medium, usually writing but also a picture, sign, or electronic broadcast.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean to take all reasonable steps to protect a trademark?},
 answer:   %{If a trademark owner fails to police his or her mark, the owner may be deemed to have abandoned the mark or acquiesced in its misuse.  A trademark is only protected while it serves to identify the source of goods or services.

If a trademark owner believes someone is infringing his or her trademark, the first thing the owner is likely to do is to write a "cease-and-desist" letter which asks the accused infringer to stop using the trademark.  If the accused infringer refuses to comply, the owner may file a lawsuit in Federal or state court.  The court may grant the plaintiff a preliminary injunction on use of the mark -- tell the infringer to stop using the trademark pending trial. 

If the owner successfully proves trademark infringement in court, the court has the power to: order a permanent injunction; order monetary payment for profit the plaintiff can prove it would have made but for defendant's use of the mark; possibly increase this payment; possibly award a monetary payment of profits the defendant made while using the mark; and possibly order the defendant to pay the plaintiff's attorney fees in egregious cases of infringement.

Of course, the determination of infringement is actually one that will be made by the court, so a trademark owner is simply using a best guess about whether or not infringement actually has occurred.  That best guess may be a good one, based on experience and expertise, or it may be a bad one that doesn't reflect any of the legitimate defenses that might exist.  The law doesn't require the mark owner to sue everyone; it just requires the owner to keep his mark distinctive.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is defamation?},
 answer:   %{Generally, defamation is a false and unprivileged statement of fact that is harmful to someone's reputation, and published "with fault," meaning as a result of negligence or malice. State laws often define defamation in specific ways. Libel is a written defamation; slander is a spoken defamation.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trade dress?},
 answer:   %{The term, trade dress, originally referred to a product's packaging.  A trade dress extends to the total image of a product or service.  }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{what is the difference between statutory and common law right of publicity?},
 answer:   %{States protect the right to control the use of one's likeliness by others if the use causes harm.  In California, the common law gives broader protection to the right of publicity than the California statute.  In California the common law prohibits the knowing appropriation of a name or likeness and the evocation of someone's identity if 1. someone used another's identity, 2. the use gave commercial or other advantage, 3, the appropriation was without consent, and, 4, the misappropriation of the identity financially harmed the bearer of that identity.  The statute in California gives less protection. The statute only prohibits appropriation of name, voice, likeness or signature, for the purpose of buying or selling.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the Lanham Act protect against misappropriation of likeness?},
 answer:   %{The Lanham Act may prohibit the unauthorized use of a celebrity's identity if someone uses the likeness, voice, or other uniquely distinguishing characteristic in a way likely to make consumers believe -- falsely -- that the celebrity sponsors, approves of, or is associated with the unauthorized user's goods or services.  }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "actual and statutory damages" for a right of publicity claim?},
 answer:   %{In a right of publicity claim, actual damages is the loss the plaintiff suffered due to the misappropriation of identity.  The statutory damages is a minimum fine the court can assess, particularly if actual damages are difficult to assess.  In California the minimun for statutory damages is $300.
}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "goodwill"?},
 answer:   %{Goodwill is a business or trademark owner's image, relationship with customers and suppliers, good reputation, and expectation of repeat patronage.  It is the value a trademark owner builds in a brand.
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "counterfeit" mark?},
 answer:   %{The Lanham Act defines a counterfeit mark as a false mark which is identical to or substantially indistinguishable from a registered mark.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is fair use?},
 answer:   %{The fair use doctrine says that otherwise copyrighted works may be used for purposes such as criticism, comment, news reporting, teaching, scholarship, or research. To decide whether a use is "fair use" or not, courts consider:

(1) the purpose and character of the use, including whether such use is of a commercial nature or is for nonprofit educational purposes;
(2) the nature of the copyrighted work;
(3) the amount and substantiality of the portion used in relation to the copyrighted work as a whole; and
(4) the effect of the use upon the potential market for or value of the copyrighted work.

}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is fair use?},
 answer:   %{The fair use doctrine says that otherwise copyrighted works may be used for purposes such as criticism, comment, news reporting, teaching, scholarship, or research. To decide whether a use is "fair use" or not, courts consider:

(1) the purpose and character of the use, including whether such use is of a commercial nature or is for nonprofit educational purposes;
(2) the nature of the copyrighted work;
(3) the amount and substantiality of the portion used in relation to the copyrighted work as a whole; and
(4) the effect of the use upon the potential market for or value of the copyrighted work.

}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the provisions of 17 U.S.C. Section 512(c)(3) & 512(d)(3)?},
 answer:   %{Section 512(c)(3) sets out the elements for notification under the DMCA.  Subsection A (17 U.S.C. 512(c)(3)(A)) states that to be effective a notification must include: 1) a physical/electronic signature of a person authorized to act on behalf of the owner of the infringed right; 2) identification of the copyrighted works claimed to have been infringed; 3) identification of the material that is claimed to be infringing or to be the subject of infringing activity and that is to be removed; 4) information reasonably sufficient to permit the service provider to contact the complaining party (e.g., the address, telephone number, or email address); 5) a statement that the  complaining party has a good faith belief that use of the material is not authorized by the copyright owner; and 6) a statement that information in the complaint is accurate and that the complaining party is authorized to act on behalf of the copyright owner.  Subsection B (17 U.S.C. 512(c)(3)(B)) states that if the complaining party does not substantially comply with these requirements the notice will not serve as actual notice for the purpose of Section 512.

Section 512(d)(3), which applies to "information location tools" such as search engines and directories, incorporates the above requirements; however, instead of the identification of the allegedly infringing material, the notification must identify the reference or link to the material claimed to be infringing.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does this information apply in other countries too?},
 answer:   %{Chilling Effects is a United States organization and information on this website is based on U.S. law.  Other countries' laws differ, often significantly, so you should not assume that the analyses presented here apply outside the United States.    If you have further questions about non-U.S. law, we recommend contacting a lawyer in your jurisdiction.}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{ISP as Copyright Cop},
 answer:   %{Notice that this letter comes from an Internet Service Provider (ISP) and not from a copyright owner.  The Digital Millenium Copyright Act both protects ISPs from copyright liability (leaving the end user with that liability) and requires ISPs to participiate in a "takedown" process when copyright owners claim infriging use.  See the FAQs associated with this notice for more information.}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is spam?},
 answer:   %{"Spam" is generally used to refer to unsolicited bulk email or usolicited commercial email.  }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Someone has alleged that, by putting the process for running their equipment on a web page, I have infringed their copyrights. Are they right?},
 answer:   %{No. Copyright does not cover ideas, processes, procedures, systems, or methods of operation.  See <a href="http://www4.law.cornell.edu/uscode/17/102.html#102.b">Sec. 102(b)</a>}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{What is due diligence?},
 answer:   %{Due diligence is an intellectual property investigation that, among other things, determines what the intellectual property is,  who owns the rights to the property, and whether those rights are enforceable.  The information can then be used to evaluate the viability of a particular business transaction. }
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What may be copyrighted?},
 answer:   %{.
In order to be copyrightable, a work must be <br>
<br>
1. fixed in a tangible medium of expression ; and<br>

2. original.<br>
<br>
Copyrights do not protect ideas, procedures, processes, systems, methods
of operation, concepts, principles, or discoveries: they only protect physical
representations. <a HREF="http://cyber.law.harvard.edu/property/library/copyrightact.html#anchor2582953">17
U.S.C. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the criteria a service provider must satisfy in order to qualify for safe harbor protection under Subsection 512(a) of the Digital Millennium Copyright Act?
},
 answer:   %{Subsection 512(a) provides a safe harbor for service providers in regard to communications that do not reside on the service provider}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Who may hold a copyright?},
 answer:   %{.
A copyright ordinarily vests in the creator or creators of a work (known
as the author(s)), and is inherited as ordinary property. Copyrights are
freely transferrable as property, at the discretion of the owner. <a HREF="http://cyber.law.harvard.edu/property/library/copyrightact.html#anchor549701">17
U.S.C. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What does the text of the "Lanham Act" state?},
 answer:   %{[not yet answered]}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Where is fair use in the Copyright Act?},
 answer:   %{Section 107.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the criteria a service provider must satisfy in order to qualify for safe harbor protection under Subsection 512(a) of the Digital Millennium Copyright Act?},
 answer:   %{Subsection 512(a) provides a safe harbor for service providers in regard to communications that do not reside on the service provider}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the First Amendment protect online speech? },
 answer:   %{The <a href="http://www.law.cornell.edu/constitution/constitution.billofrights.html#amendmenti" target="new">First Amendment</a> to the U.S. Constitution says that "Congress shall make no law ... abridging the freedom of speech, or of the press."  Under the First Amendment and cases interpreting it, the federal government (and states, under the Fourteenth Amendment) must meet a high level of scrutiny before restricting any kind of speech.  In the first Supreme Court case dealing with the Internet, <a href="http://supct.law.cornell.edu/supct/html/96-511.ZO.html" target="new">Reno v. ACLU</a>, the Supreme Court affirmed that online speech deserves as much protection as off-line speech. }
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{What is malice?},
 answer:   %{According to Black's Law Dictionary, malice is "the intent, without justification or excuse, to commit a wrongful act."  The dictionary further defines malice as "reckless disregard of the law or of a person's legal rights."  The adjective "malicious" is defined to also include those acts which are "substanitally certain to cause injury." }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a Business Interference Campaign?},
 answer:   %{The phrase is probably used to signify attempts to interfere with a business relationship (also known as commiting "tortious interference with prospective advantage").  The latter is defined by Black's Law Dictionary as "an intentional, damaging intrusion on another's potential business relationship, such as the opportunity of obtaining customers or employment."}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is good faith?},
 answer:   %{Good faith is defined by Black's Law Dictionary as "a state of mind consisting in ... honesty in belief or purpose ... or absence of intent to defraud or to seek unconscionable advantage."  Good faith can be a defense to legal claims where the plaintiff must establish that the defendant had a particular state of mind, such as an intent to do harm.  Essentially, it is a defense that can be used by the defendant to establish that he or she was void of the requisite mental culpability necessary to hold him or her liable for an alleged harm.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Why does the author care if the purpose of the recipient's acts was to engage in political debate or commentary?},
 answer:   %{Because comments made for purposes of political debate or commentary  are protected free speech under the First Amendment, if made in good faith.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Does copyright protect words or short phrases?},
 answer:   %{No.  Names, titles, and short phrases are not subject to copyright protection.  These are not deemed to be "original works of authorship" under the Copyright Act.  Names  may be protected by trademark, in some instances.  See the <!--GET FAQLink 6--> FAQ for more information.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the "trespass to chattels" claims some companies or website owners have brought?},
 answer:   %{Some Internet companies have claimed that unauthorized use of their servers, such as unsolicited email or robot-generated hits to websites, are a "trespass" to those servers by depriving the owners of the full use of their machines.   eBay won an injunction stopping Bidder's Edge from automatically spidering the eBay site to generate auction comparison listings, because the robotic crawler used eBay system resources.  The caselaw is far from settled in this area, and some commentators argue that technical means to block the use are more appropriate than legal action.
<p>
See <a href="http://www.tomwbell.com/NetLaw/Ch06.html">Tom W. Bell's online casebook</a> for more information about trespass claims.}
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{What does perpetuity mean?},
 answer:   %{Black's Law Dictionary defines perpetuity as "the state of continuing forever."  So in this context the writer of the cease and desist letter is trying to make the recipient agree never to post to the mentioned websites ever again.}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "interference with contract" or "interference with prospective business relations"?},
 answer:   %{One can be held liable for intentionally or negligently interfering with the  existing or prospective economic relationships of another. (e.g. contractual/business relationships)  

The 2d restatement of the law which contain general defintions of the law taken from the laws of many states, defines the tort of Intentional Interference with Prospective Contractual Relations as follows:
"One who intentionally and improperly interferes with another's prospective contractual relation (except a contract to marry) is subject to liability to the other for the pecuniary harm resulting from loss of the benefits of the relation, whether the interference consists of

(a) inducing or otherwise causing a third person not to enter into or continue the prospective relation or
(b) preventing the other from acquiring or continuing the prospective relation."
Rest 2d (Torts) section 766B.




Usually, damages are dependent on proof that "but for" the allegedly interfering behavior, an economic relationship, the contract, would have been entered into. 

Most jurisdictions and the restatement have slightly different wording for the seperate tort of interference with an already existing contractual relationship.(e.g. when a 3rd party's behavior prevents the performance of or induces the breach of a pre-existing contract)


   }
)

mapping[%{Uncategorized}] << q.id

q = RelevantQuestion.create!(
 question: %{What rights does a domain owner have?},
 answer:   %{There are no rights that flow simply from registering a domain name; in fact domain name registrants do not even "own" the domain, they simply lease the service that resolves the domain name to certain files such as websites.  In the US, one acquires legaL rights to names by registering them with a government trademark authority or by actually using them to identify the origina of goods or services.  

However, some domain names have also been used as trademarks (such as amazon.com) and many domain names contain existing trademarks (sony.com), therefore it is important to know whether or not one may be violating these underlying rights in a name that appears in a domain.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I copy an entire news article from a commercial news web site and post the article on my web site?},
 answer:   %{The fair use doctrine, as currently interpreted by the courts, probably would not entitle you to do so.  Even though news items are factual and facts themselves are not protected by copyright, an entire news article itself is expression protected by copyright.  

A court would apply the four factor fair use analysis to determine whether such a use is fair.  In Los Angeles Times v. Free Republic, the court found that such a use was minimally -- or not at all -- transformative, since the article ultimately served the same purpose as the original copyrighted work.  The initial posting of the article was a verbatim copy of the original with no added commentary or criticism and therefore did not transform the work at all.  Although it is often a fair use to copy excerpts of a copyrighted work for the purpose of criticism or commentary, the copying may not exceed the extent necessary to serve that purpose.  In this case, the court found that only a summary and not a complete verbatim copy of the work was necessary for the purpose of commentary and criticism.  

The court also found that although the website solicited donations and advertised the services of another website, the overall nature of the website was non-commercial and benefited the public by promoting discussion of the issues presented in the articles on the website.  However, the court found that the nontransformative character of the copying outweighed the consideration of its minimally commercial nature.  

Finally, and most importantly, the court found that posting entire news articles on the website had an adverse market effect on the copyright owners.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{When is parody protected from a charge of trademark infringement?},
 answer:   %{Parody is a usage of a mark that pokes fun at the mark and does not confuse the public as to the source of the usage. In determining whether there is infringement the court balances the public interest in free expression against the public interest in avoiding consumer confusion. "A parody must convey two simultaneous--and contradictory messages; that it is the original, but also that it is not the original and is instead a parody. To the extent that it does only the former but not the latter, it is not only a poor parody but also vulnerable under trademark law, since the consumer will be confused."  From Cliffs NOtes, Inc. v. Bantam Doubleday Dell Publishing Group, 886 F. 2d 490 (2d Cir. 1989)}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the significance of Section 512(a) of the DMCA to service providers?},
 answer:   %{If a service provider falls within the requirements of subsection 512(a), then it will not be liable for monetary, injunctive, or other equitable relief.  Specifically, it will not be liable for copyright infringement by reason of (1) the service provider}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the significance of Section 512(a) of the DMCA to service providers?},
 answer:   %{If a service provider falls within the requirements of subsection 512(a), then it will not be liable for monetary, injunctive, or other equitable relief.  Specifically, a service provider will not be liable for copyright infringement by reason of (1) the service provider}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{If a service provider qualifies for protection under one of the DMCA section 512 safe harbors, does this preclude the service provider from protection under other 512 safe harbors?},
 answer:   %{Whether a service provider is entitled to protection under any one of subsections 512(a) - 512(d) will be based solely on the criteria in that subsection and will not affect a determination of whether that service provider qualifies for limitations on liability under any other subsection 512(a) - (d) [512(n)].  }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the criteria a service provider must satisfy in order to qualify for safe harbor protection under Subsection 512(a) of the Digital Millennium Copyright Act?},
 answer:   %{Subsection 512(a) provides a safe harbor for service providers in regard to communications that do not reside on the service provider}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What rights are associated with a movie or TV show?},
 answer:   %{.
An audiovisual work can be covered by several overlapping "intellectual property" rights.  These might include: 
<ul><li>Copyrights in the images, story, musical compositions, and sound recordings
<li>Trademark in the name of a series or producer
<li>Rights of publicity for the actors
</ul>}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Are legal documents copyrightable?},
 answer:   %{Legal documents such as briefs, contracts, and even cease-and-desist letters written by private attorneys (but not by government lawyers) may be protected by copyright like any other material "fixed in a tangible medium of expression."  However, greater fair use defenses may be available to those who copy legal documents.  For example, it may be uniquely necessary to use the precise language of the document; the document may have little "creative" input; and its copying may not impact the market for legal services.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a SLAPP suit?},
 answer:   %{SLAPP stands for Strategic Lawsuit Against Public Participation, or lawsuits aimed at squelching speech and involvement in government.  Many states, including California, have anti-SLAPP statutes allowing one who has been targeted by a SLAPP to sue back.

Online, SLAPP suits typically involve a person who has posted anonymous criticisms of a corporation or public figure on the Internet. The target of the criticism then files a lawsuit so they can issue a subpoena to the Web site or Internet Service Provider (ISP) involved and thereby discover the identity of their anonymous critic. Many SLAPPers stop after discovering their critic's identity, using the tactic to intimidate or silence online speakers even though they were engaging in protected expression under the First Amendment.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is RICO?},
 answer:   %{RICO is short for the Racketeer-Influenced and Corrupt Organizations Act, which allows individuals to file suit against people who engage in "racketeering."  Racketeering can include a variety of statutorily defined crimes; mail and wire fraud are the most common examples.  A brief guide to this quite complex statute is available at http://www.ricoact.com}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{What is tortious interference with a business relationships?},
 answer:   %{Tortious interference with a business relationship is a claim by a contracting party against a third party for unjustified interference with the contractual relationship. To establish a claim for interference with contract, a plaintiff must plead and prove: (1) a valid and existing contract between plaintiff and a third party; (2) defendant's knowledge of this contract; (3) defendant's intentional acts designed to induce a breach or disruption of the contractual relationship; (4) actual breach or disruption of the contractual relationship; and (5) resulting damage. }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Where is the fair use doctrine codified?},
 answer:   %{The fair use doctrine was originally a judge-made doctrine embodied in case law.  See Folsom v. Marsh, 9 F.Cas. 342 (1841).   Congress later codified it at Title 17 of the United States Code, Section 107.   

This section provides:
  
Section 107. Limitations on exclusive rights: Fair use 
 
Notwithstanding the provisions of sections 106 and 106A [setting forth copyright owners' exclusive rights and visual artists' artistic rights], the fair use of a copyrighted work, including such use by reproduction in copies or phonorecords or by any other means specified by that section, for purposes such as criticism, comment, news reporting, teaching (including multiple copies for classroom use), scholarship, or research, is not an infringement of copyright. In determining whether the use made of a work in any particular case is a fair use the factors to be considered shall include }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{May I post the name, phone number, or address of an individual on my webpage?},
 answer:   %{The common law in most states protects an individual's right to privacy.  State laws differ.  However, according to the Restatement of Torts (Second), which is a guide to general tort law, one's privacy may be invaded by (1) an intrusion upon seclusion, (2) appropriation of name or likeness, (3) publicity of one's private life, or (4) publicity placing one in a false light.  

It would therefore seem that under the Restatement, the mere publication of a person's address, no matter what the circumstances, could not constitute an invasion of his privacy. This issue has seldom been raised, and when it has, the courts have generally held that the publication of a person's residential address is not an invasion of his privacy, particularly if that information is published elsewhere. 

However, if the information was released for the purpose of facilitating violence against the person, the publisher may not be protected by the First Amendment and could be subject to criminal and civil penalties.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What title is copyright act?},
 answer:   %{Title 17}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Is this a test question?},
 answer:   %{Yes it is.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What good is a disclaimer?},
 answer:   %{A disclaimer can help tell visitors what a website site is and isn't.  Much of trademark law aims to prevent consumer confusion; a disclaimer of sponsorship or association with the trademark holder could help avoid confusion.  In defamation law, statements of opinion are protected, but false statements of fact can be defamatory; a disclaimer could emphasize the opinion nature of a website.  A disclaimer can help the humor-impaired to understand a parody site. 

A disclaimer won't tip the balance on a site that is blatantly violating the law, though, and one may not be necessary if the nature of the website is clear from its face.  Think of it as a little special sauce.  }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What defenses are there to trademark infringement or dilution?},
 answer:   %{.
Defendants in a trademark infringement or dilution claim can assert
basically two types of affirmative defense: fair use or parody.  
<p>
<b>Fair use</b> occurs when a descriptive mark is used in
good faith for its primary, rather than secondary (trademark),
meaning, and no consumer confusion is likely to result.  So, for
example, a cereal manufacturer may be able to describe its cereal as
consisting of "all bran," without infringing upon Kelloggs' rights in
the mark "All Bran."  Such a use is purely descriptive, and does not
invoke the secondary meaning of the mark.  Similarly, in one case, a
court held that the defendant's use of "fish fry" to describe a batter
coating for fish was fair use and did not infringe upon the plaintiff's
mark "Fish-Fri." <a href="http://cyber.law.harvard.edu/metaschool/fisher/domain/tmcases/zatar.htm">Zatarain's, Inc. v. Oak
Grove Smokehouse, Inc., 698 F.2d 786 (5th Cir. 1983)</a>.  Such uses are
privileged because they use the terms only in their purely descriptive
sense.
<p>
Some courts have recognized a somewhat different, but closely-related,
fair-use defense, called <b>nominative use</b>.  Nominative use occurs when use
of a term is necessary for purposes of identifying another producer's
product, not the user's own product.  For example, in a recent case, the
newspaper USA Today ran a telephone poll, asking its readers to vote for
their favorite member of the music group <a
href="http://www.yahoo.com/Entertainment/Music/Artists/By_Genre/
Rock_and_Pop/New_Kids_on_the_Block/">New Kids on the Block</a>.  The New
Kids on the Block sued USA Today for trademark infringement.  The court
held that the use of the trademark "New Kids on the Block" was a
privileged nominative use because: (1) the group was not readily
identifiable without using the mark; (2) USA Today used only so much of
the mark as reasonably necessary to identify it; and (3) there was no
suggestion of endorsement or sponsorship by the group.  The basic idea
is that use of a trademark is sometimes necessary to identify and talk
about another party's products and services.  When the above conditions
are met, such a use will be privileged. <a
href="http://cyber.law.harvard.edu/metaschool/fisher/domain/tmcases/newkids.htm">New Kids on the Block v. News America
Publishing, Inc., 971 F.2d 302 (9th Cir. 1992)</a>.
<p>
Finally, certain <b>parodies</b> of or using trademarks may be permissible if they are not too directly tied to commercial use.  The basic idea here is that
artistic and editorial parodies of trademarks serve a valuable critical
function, and that this critical function is entitled to some degree of
First Amendment protection.  The courts have adopted different ways of
incorporating such First Amendment interests into the analysis.  For
example, some courts have applied the general "likelihood of confusion"
analysis, using the First Amendment as a factor in the analysis.  Other
courts have expressly balanced First Amendment considerations against
the degree of likely confusion.  Still other courts have held that the
First Amendment effectively trumps trademark law, under certain
circumstances.  In general, however, the courts appear to be more
sympathetic to the extent that parodies are less commercial, and less
sympathetic to the extent that parodies involve commercial use of the
mark.
<p>
So, for example, a risqu? parody of an L.L. Bean magazine advertisement (L.L. Beam's "Back to School Sex Catalog") was found not to constitute infringement. <a
href="http://cyber.law.harvard.edu/metaschool/fisher/domain/tmcases/llbean.htm">L.L. Bean, Inc. v. Drake Publishers, Inc., 811
F.2d 26, 28 (1st Cir. 1987)</a>.  Similarly, the use of a pig-like
character named "Spa'am" in a Muppet movie was found not to violate
Hormel's rights in the trademark "Spam." <a
href="http://cyber.law.harvard.edu/metaschool/fisher/domain/tmcases/hormel.htm">Hormel Foods Corp. v. Jim Henson Prods., 73
F.3d 497 (2d Cir. 1996)</a>.  On the other hand, "Gucchie Goo" diaper
bags were found not to be protected under the parody defense, <a
href="http://cyber.law.harvard.edu/metaschool/fisher/domain/tmcases/gucci.htm">Gucci Shops, Inc. v. R.H. Macy & Co., 446 F.
Supp. 838 (S.D.N.Y. 1977)</a>.  Similarly, posters bearing the logo
"Enjoy Cocaine" were found to violate the rights of Coca-Cola in the
slogan "Enjoy Coca-Cola", <a href="http://cyber.law.harvard.edu/metaschool/fisher/domain/tmcases/coca.htm">Coca-Cola Co. v. Gemini Rising, Inc., 346 F. Supp. 1183 (E.D.N.Y. 1972)</a>.  In short -- although the courts recognize a parody defense, the precise contours of that defense are difficult to outline with any precision.<p>
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What does the PTO's refusal to register a trademark mean?},
 answer:   %{The Trademark Office can reject a proposed mark for a number of reasons, for example, that the term does not function as a trademark (does not identify the source of goods or services), that the term is generic for the goods or services, or that the term is likely to cause confusion with an existing registered mark.  Further, an application might be rejected because of non-compliance with procedural rules, such as improperly specifying the class in which the mark is used.  If the applicant does not respond to the "office action", the application is abandoned.

See the <a href="http://www.uspto.gov/web/offices/tac/tmfaq.htm#Application011">Trademark Office's Frequently Asked Questions</a> for more.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the PTO's refusal to register a mark mean the mark infringes someone else's trademark?},
 answer:   %{No.  Even if the Trademark Examiner <a href="http://www.uspto.gov/web/offices/tac/tmep/1200.htm#_Toc2665974">refuses registration of a mark on the grounds of likelihood of confusion</a>, that does not mean use of the term infringes a trademark.  Only a court can rule as a factual matter that the likelihood of confusion amounts to trademark infringement.}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{In general, what types of uses does the fair use doctrine protect?},
 answer:   %{Fair use is a defense to a claim of copyright infringement.  The language used by Congress to codify the fair use defense to copyright infringement (set forth in <a href="http://www4.law.cornell.edu/uscode/17/107.html" target="new">Title 17, Section 107</a>) specifically lists criticism, comment, news reporting, teaching, scholarship, and research as examples of uses that might be protected under fair use. However, this list is non-exhaustive, and therefore a use not covered in one of the categories could nonetheless be successfully defended as a fair use.  Conversely, not every use that falls within the listed categories will necessarily be found by a court to be fair.  For example, not every use of another's work for research or educational purposes will be held to be a fair use.

In considering a fair use defense to a claim of infringement, a court will focus its inquiry on the specific facts of the individual case. Therefore, it is very difficult to predict with accuracy what a court will do until it engages in the inquiry. What we do know is that a court will use the four factors listed by Congress as a guide in its inquiry. The four factors listed are 
<ol>
<li> the purpose and character of the use (the more transformative defendant's use, the more likely to be fair use, whereas if defendant merely reproduces plaintiff's work without putting it to a transformative use, the less likely this use will be held to be fair; further, the more commercial defendant's use, the less likely such use will be fair), 
<li> the nature of the copyrighted work (first, the more creative and less purely factual the copyrighted work, the stronger its protection; second, if a copyrighted work is unpublished, it will be harder to establish that defendant's use of it was fair), 
<li> the amount and substantiality of the portion defendant used (did defendant copy nearly all of, or the heart of, the copyrighted work? if so, such use is less likely to be fair) and 
<li> the effect of defendant's use on the potential market for the copyrighted work.  
</ol>
The fourth factor -- the effect of defendant's use on plaintiff's market (or potential market) for her creative work -- is generally held to be the most important. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Is my parody of another's copyrighted work protected as a fair use?
},
 answer:   %{It is likely that a bona fide parody that does not usurp the market for plaintiff's work or unfairly free ride on plaintiff's work will be protected as a fair use. Courts have held that the fair use defense can protect a parody of a copyrighted work from an infringement claim.  However, that does not necessarily mean that all parodies will be protected.  In the case of a parody where the defendant raises a fair use defense, the courts will run through the four part fair use analysis just as they would with any other fair use test.  [See <a href="<!--GET URL Question 492-->">above</a> for the four part test].

While it is problematic to try to predict what a court will decide in any fair use case, it is likely that in the case of a parody the court will focus on the fourth factor of the inquiry, which requires the court to ask what effect the parody has on the potential market for the copyrighted work.  If the parody usurps the market for the copyrighted work, then there is an increased chance that the court will find that the use is not fair.  If the parody dampens the market for the copyrighted work as a result of its implicit criticism of the work, such a negative effect on the market does not render such use unfair.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the purpose of the fair use defense?},
 answer:   %{There is no easy answer to this question.  However, one way to approach the question is to examine the purposes of the copyright laws.  

The clause of the Constitution that gives Congress the power to enact copyright laws indicates that the purpose of the given power is to "promote the progress of science and the useful arts" by allowing authors to secure the exclusive rights in their works for "limited times."  Thus, many see the Constitutional scheme behind copyright as a kind of balance between (1) forming incentives for authors to create new works by giving them rights that will allow them to make money from their works, and (2) limiting the rights so that the works themselves are useful to the public and in turn advance the "progress of science and the useful arts."  

Fair use fits into this scheme by giving the public the right to use copyrighted works in certain situations even though the author has exclusive rights.  That is, in some circumstances, such as certain uses involving scholarship or research, the "progress" referred to in the Constitution is best promoted and the public is best served by allowing a use of the copyrighted work.  These uses are deemed fair because they are consistent with the power given to Congress to enact copyright laws.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the purpose of the fair use defense? 
},
 answer:   %{There is no easy answer to this question. However, one way to approach the question is to examine the purposes of the copyright laws.  

The clause of the Constitution that gives Congress the power to enact copyright laws indicates that the purpose of the given power is to "promote the progress of science and the useful arts" by allowing authors to secure the exclusive rights in their works for "limited times." Thus, many see the Constitutional scheme behind copyright as a kind of balance between (1) forming incentives for authors to create new works by giving them rights that will allow them to make money from their works, and (2) limiting the rights so that the works themselves are useful to the public and in turn advance the "progress of science and the useful arts."  

Fair use fits into this scheme by giving the public the right to use copyrighted works in certain situations even though the author has exclusive rights. That is, in some circumstances, such as certain uses involving scholarship or research, the "progress" referred to in the Constitution is best promoted and the public is best served by allowing an unauthorized use of the copyrighted work. These uses are deemed fair because they are consistent with the power given to Congress to enact copyright laws.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is fair use?},
 answer:   %{Fair use is an affirmative defense that can be raised by an individual who is sued for copyright infringement (or an individual against whom a claim of copyright infringement is alleged).  See Campbell v. Acuff-Rose Music, Inc., 510 U.S. 569 (1994).  Once the plaintiff has proven that his or her copyright was infringed upon, the burden lies with the defendant who invokes the fair use defense to prove that her or his use of the copyrighted work of another should be legally permitted, notwithstanding the copyright owner's exclusive rights in her work. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I use fair use to force a copyright holder to turn over her or his copyrighted work to me so that I can copy it and use it?
},
 answer:   %{No.  Fair use is a defense to a claim of infringement.  Therefore, someone who wishes to make a use of the copyrighted work of another cannot force the copyright holder to turn over the work, even if the desired use would be considered fair by the courts.  In such a case, the user must find a way to make the use, and then can invoke the fair use defense if she or he is sued for infringement by the copyright holder.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Where is the fair use doctrine codified?},
 answer:   %{The fair use doctrine, originally a judge-made doctrine embodied in case law, is now codified at <a href="http://www4.law.cornell.edu/uscode/17/107.html" target="new">Title 17 of the United States Code, Section 107</a>.  This section provides:

Section 107. Limitations on exclusive rights: Fair use

Notwithstanding the provisions of sections 106 and 106A [setting forth copyright owners' exclusive rights and visual artists' artistic rights], the fair use of a copyrighted work, including such use by reproduction in copies or phonorecords or by any other means specified by that section, for purposes such as criticism, comment, news reporting, teaching (including multiple copies for classroom use), scholarship, or research, is not an infringement of copyright. In determining whether the use made of a work in any particular case is a fair use the factors to be considered shall include }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{If I am engaged in research, educational, or academic pursuits, does the fair use doctrine permit me to copy articles from a journal or periodical?},
 answer:   %{As mentioned above, it is hard to predict what a court will do when presented with a fair use defense. However, in this case the answer depends in part on your purposes in copying. If you intend to archive the copies, the answer is probably no, while if you intend to use the copies in classroom instruction (without charging for the copies), the use may be fair.  

In 1994 the Second Circuit Court of Appeals held that it was not a fair use for research scientists at Texaco to photocopy articles from various scientific and technical journals. Texaco argued, on behalf of its scientists, that the use was for the purpose of research, and therefore was fair under Section 107. But the court was not convinced. In reaching its decision, the court in Texaco ran through the four factor fair use analysis (see generally, what types of uses does the fair use doctrine protect? and the introduction to this Lumen topic). The court found that three of the four factors weighed against Texaco, and focused much of its opinion on the fourth factor, deciding that Texaco's use would have a significant impact on the potential market for the journal articles. Thus, in order to make copies of the articles, the research scientists at Texaco had to either pay for them or get express permission from the publishers.  See American Geophysical Union v. Texaco Inc., 60 F.3d 913 (2d Cir. 1994).  

Further, use of another's work for classroom instruction purposes may be protected under a separate provision of the Copyright Act. Section 110 of the Copyright Act contains exemptions that provide nonprofit educational institutions the limited right to use copyrighted materials in face-to-face classroom settings. This section provides: "Notwithstanding the provisions of section 106, the following are not infringements of copyright: (1) performance or display of a work by instructors or pupils in the course of face-to-face teaching activities of a nonprofit educational institution, in a classroom or similar place devoted to instruction . . . ."  

Furthermore, the recently enacted "Technology, Education, and Copyright Harmonization Act" -- the TEACH Act -- amends Section 110 to exempt certain uses of copyrighted works in the context of distance education (beyond the context of face-to-face teaching). The TEACH Act sets forth in detail the terms and conditions on which nonprofit educational institutions may use copyrighted works in the context of distance education (such as via websites or other digital means) without permission. 

}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{As an owner of a commercial copyshop, can I make copies of copyrighted works of scholarship, bind them in coursepacks, and sell them to students for use in fulfilling reading assignment given by their professors?  
},
 answer:   %{While it is difficult to predict what courts will do when faced with a fair use defense, the answer is probably no.  In 1997 the Sixth Circuit Court of Appeals held that it was not fair use for Michigan Document Services, a commercial copyshop, to copy works of scholarship and sell them to students without the permission of the copyright hodlers.  

The court ran through the four factor fair use analysis (see 17 USC Section 107: see Introduction to this Chilling Effects topic; see answer to FAQ: "what does the fair use defense protect?"), focusing on the effect that the copying would have on the potential market for the copyrighted works.  The court found that the copying would have a significant impact on the potential market for the works and consequently found that the copying was not protected by the fair use defense.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Suppose the owner of a copyrighted work displays this work on her/his website and places technological barriers on the work that prevent me from copying it.  Does the fair use doctrine require the owner of such copyrighted work to remove those technological barriers if I can prove that my copying would be a fair use?  },
 answer:   %{No.  Fair use provides a defense to a claim of copyright infringement, but (according to most courts, at least) does not provide the would-be copier with the affirmative right (or ability) to copy.  That is, you cannot force a copyright holder to give you copies of a work or allow you to make copies of the work.  Under current copyright law, it is perfectly lawful for a copyright holder to use technological barriers to prevent others from making copies of her/his work.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{If the owner of a copyrighted work that is displayed on a website uses technological measures to prevent me from copying the work onto my website, but my copying would be a fair use, can I use technological measures to circumvent the protection and make the copy anyway?},
 answer:   %{Yes.  Under the current copyright laws, it is lawful to circumvent technological copyright protection systems in order to make a copy.  Then, if the copyright holder sues you for making the copies, and your fair use defense is successful, you are in the clear.  But here's the catch:  It is UNLAWFUL for someone to traffic in technology that can be used to circumvent technological copyright protection systems.  Therefore, unless you can circumvent the copyright holder's protection yourself, it is unlikely that you will be able to find the technology you need elsewhere. Note that it is also UNLAWFUL for you to circumvent <b>access</b> control technologies.  See <a href="http://www.copyright.gov/title17/92chap12.html" target="new">Chapter 12 of the Copyright Act</a>, particularly <a href="http://static.chillingeffects.org/1201.html">section 1201</a>.  For more information on the anticircumvention provisions, see the Chilling Effects topic <!--GET CatLink 12-->.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What does the text of the "Lanham Act" state?},
 answer:   %{[not yet answered]}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{How is Internet anonymity affected by Section 512(h) subpoenas?},
 answer:   %{Since anyone who has ever written or typed something is a copyright holder, it is possible that any of these people might misuse the Section 512(h) subpoena to discover identity for purposes other than vindicating copyright rights.  In some instances, the fear of improper discovery of their identity will intimidate or silence online speakers even though they were engaging in protected expression under the First Amendment. }
)

mapping[%{DMCA Subpoenas}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "motion to quash" a subpoena?},
 answer:   %{This is a formal request for a court to rule that your information should not be given to the requesting party.  This normally includes the request, plus a legal brief (sometimes called a memorandum of points and authorities) explaining why, by law, your information should not be turned over.  Samples of briefs filed in John Doe cases are available at:

<a href="http://www.eff.org/Privacy/Anonymity/Cullens_v_Doe/">EFF Archive, Cullens v. Doe, http://www.eff.org/Privacy/Anonymity/Cullens_v_Doe/</a>
<a href="http://www.citizen.org/litigation/briefs/IntFreeSpch/articles.cfm?ID=5801">http://www.citizen.org/litigation/briefs/IntFreeSpch/articles.cfm?ID=5801</a>}
)

mapping[%{DMCA Subpoenas}] << q.id

q = RelevantQuestion.create!(
 question: %{What does "respond" to the subpoena mean?},
 answer:   %{Usually, it means that the ISP will give the requested information to the requesting person.  In some cases, ISPs have resisted requests for information on behalf of their customers, but this is not the norm.  Unless specifically told differently by your ISP, you should assume that your ISP will turn over your information as part of its response.}
)

mapping[%{DMCA Subpoenas}] << q.id

q = RelevantQuestion.create!(
 question: %{Is there a difference between reporting on public and private figures?},
 answer:   %{Yes. A private figure claiming defamation }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Trademark Misuse?},
 answer:   %{Trademark Misuse is a theoretical concept which pertains to how a trademark holder handles its rights.  It purports to be similar to the defenses brought in copyright and patent cases, which dictate that if the owner of the intellectual property rights (e.g. a patent or copyright) over-exerts its rights (e.g forces someone to buy an unrelated product to gain acess to the protected work), then the copyright or patent holder will lose its right to sue for infringement. 

Recently, the theory was employed in challenging Network Solutions' dispute policy which held that registered trademark holders had the right to have Network Solutions immediately freeze any allegedly infringing domain names until the dispute was settled.  It was argued that often claims with little or no support were being alleged by Registered Trademark Holders so as to prevent possibly infringing sites from materializing.  Although the trademark holder's registration (and rights) were not cancelled, the argument that giving "extra" rights to registered trademark holders was unfair ultimately led to a change in Network Solution's dispute policy.

It is believed that the trademark misuse theory may still prove useful where a domain name owner is forced by a trademark owner to litigate or arbitrate a frivolous claim of infringement.     
 }
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the sexually explicit content of my Fan Fiction have a negative effect on my First Amendment right to free speech?},
 answer:   %{No.  Courts are not likely to bias you for any particular type of speech.  The content of your FanFic, adult or not, is your choice.  To write and speak freely is a major underlying tenet in our constitution, and, when balanced with the concerns of the copyright clause, it enables you to write about what you want to. }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the fact that my fan fiction website is adult oriented put me at a heightened risk for copyright or trademark infringement?},
 answer:   %{  Yes, and no.  The fact that your website may contain sexually explicit images or verbage regarding a particular copyright or trademark should not make a court more likely to find against you for infringement.  Content of speech, even sexually explicit speech, is not generally a valid excuse for the government to bar access to content.  There are some recent holdings with regard to filtering software in libraries that speak to this point.  
  The main issue here is that the more inflamatory (in the eyes of the copyright holder) your site is, the more likely they are to come after you.  Whether or not their claim has any validity is another question altogether.  }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Is sexually explicit Fan Fiction protected by the First Amendment right to free speech?},
 answer:   %{Yes.  However, sexually explict materials receive different levels of First Amendment protection.  For example, child pornography and obscenity are not protected by the First Amendment.  In Miller v. California (1973), the Supreme Court, in a 5-to-4 vote, ruled that material could be banned as obscene if it met a three-part test: 

1.  The average person, applying contemporary community standards, would find that the work, taken as a whole, appeals to the prurient interest; 
2.  The work depicts, in a patently offensive way, sexual conduct specifically defined by the applicable state law; 
3.  The work, taken as a whole, lacks serious literary, artistic, political or scientific value.  

Material that meets all three parts is obscene and outside of First Amendment protection. Under the decision, only "ultimate sexual acts" could be forbidden, and relevant community standards were local, not nationwide.   

Non-obscene pornography, indecent and other "adult" materials do receive some level of First Amendment protection.  }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What issues arise if my FanFic content is inappropriate for minors?  },
 answer:   %{  Age verification warnings may limit the possibility of a minor having a 
chance encounter with unsuitable material.  Some sexually-explicit content 
providers use age verification because they feel that industry-wide self 
regulation will help quell the congressional demand for stricter online 
content regulation.  

Most states have laws that prohibit the distribution of sexually-explicit 
material to underage people.  In California, for instance, it is a crime to 
distribute material "to a minor with the intent of arousing, appealing to, or 
gratifying the lust or passions or sexual desires of that person or of a 
minor..."  Cal. Pen. Code }
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "punitive damages"?},
 answer:   %{Punitive damages are damages intended to punish and deter similar wrongful conduct rather than merely compensate for losses suffered by the plaintiff (called compensatory damages).   Punitive damages are authorized when the defendant acted with recklessness, malice, or deceit.  As for the amount of punitive damages awardable, the Supreme Court has held that three guidelines help determine whether a punitive-damages award violates constitutional due process: (1) the reprehensibility of the conduct being punished; (2) the reasonableness of the relationship between the harm and the award; and (3) the difference between the award and the civil penalties authorized in comparable cases." BMW of North America, Inc. v. Gore, 517 U.S. 559, 116 S.Ct. 1589 (1996). }
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a cease and desist letter recipient have a duty to remove materials alleged to be defamatory? },
 answer:   %{No.  The cease and desist letter does not place you under an obligation to remove something.  There is no legal reason to remove the material before a court order has been issued to do so.  First Amendment Law regarding prior restraint forbids this.   
Not taking down the material, however, might have an effect on damages if a suit is brought and a judgment found in favor of the accuser.  The amount of time a defamatory statement is in the public eye can favor a higher damage award.   
The cease and desist letter gives its recipient ("you") notice that someone is claiming something you've done or something on your site that is defamatory.  It is merely a warning of concern by another party, and has no legal ramification.  
         

}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{
What effect does the content of my fan fiction have on its legality?  Is it different for sexually explicit material?
},
 answer:   %{None.  The content of your fan fiction has no effect on its legality in terms of copyright infringement.  Sexually explicit fan fiction material is no different from any other kind of content in that it is speech, and is protected by the First Amendment.  There have been several attempts in the last decade to modify the treatment of sexually explicit material on line with regard to minors (probably inapplicable anyway due to fan fiction}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What effect does the content of my fan fiction have on its legality?  Is it different for sexually explicit material?
},
 answer:   %{None.  The content of your fan fiction has no effect on its legality in terms of copyright infringement.  Sexually explicit fan fiction material is no different from any other kind of content in that it is speech, and is protected by the First Amendment.  There have been several attempts in the last decade to modify the treatment of sexually explicit material on line with regard to minors (probably inapplicable anyway due to fan fiction}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Who owns the copyright?
},
 answer:   %{
If the work is protected, then it becomes important to know who owns the copyright. A copyright can be owned by one author (the original author) or by several authors when the work is a joint work. If the work is a joint work, then all authors are co-owners and are treated like tenants in common, each having an independent right to use or grant a "non-exclusive" license. A corporation can also own works produced by its employees as "works for hire," or have creators assign copyrights to it. Thus, fan fiction authors could be dealing with individual authors such as Anne Rice or large corporations such as Fox or Viacom. 


Now that many fan fiction authors publish on the Internet, copyright holders (regardless of whether they are individual authors or corporations) can easily use search engines to discover their characters being used in unauthorized or unapproved ways. Many owners have tried to stop that use, and as a result, fan fiction authors have received letters telling them to take their stories off-line (See cease and desist letters). 

}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the effect of an age verification warning on a copyright claim?
},
 answer:   %{Age verification has no effect on copyright claims.  The validity of a copyright has to do with the similarity between the alleged infringing work and the original work, not with its suitability for minors.  
}
)

mapping[%{Fan Fiction}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a cease and desist letter recipient have a duty to remove materials alleged to be infringing? },
 answer:   %{No.  The cease and desist letter does not place you under an obligation to remove something.  There is no legal reason to remove the material before a court order has been issued to do so.  First Amendment Law regarding prior restraint forbids this.   
Not taking down the material, however, might have an effect on damages if a suit is brought and a judgment found in favor of the accuser.  The amount of time infringing material is available for download and in the public eye can favor a higher damage award.   
The cease and desist letter gives its recipient ("you") notice that someone is claiming something you've done or something on your site that is infringing on their work.  It is merely a warning of concern by another party, and has no legal ramification.  
}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Malice or "Actual Malice"?},
 answer:   %{Malice is often defined as, "the intent, without justification or excuse, to commit a wrongful act." It is the conscious, intentional wrongdoing with the intent of doing harm to do the victim. In many civil cases, a finding that a defendant acted with malice will often open the door to liability or increased damages, such as punitive damages. "Actual malice" is a legal term of art that is mainly relevant to defamaton claims. "Actual Malice" is found to be present when a false statement is published with either a) actual knowledge of its falsity or b) reckless disregard for its falsity-- a "should have known" standard.  One cannot be held liable for publishing untrue statements about public figures (or companies) without being found to have acted with "actual malice".    }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an internet service allow users to store and listen to compact disks sold by record companies through an internet connection?},
 answer:   %{Probably not.  According to the court in UMG Recordings v. MP3.Com, an internet company may not store MP3 music files to facilitate their retransmission.  Reproducing audio compact disks into MP3s does not transform the copyrighted work.  An internet operator must do more than merely retransmit the original work in a different medium.  The court in UMG also found that storing digital files in this way would have an adverse market effect on the record companies.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the fair use doctrine permit individuals to upload and download digital audio files containing copyrighted music through a file-sharing service that facilitates transmission and retention of the files by its users?},
 answer:   %{The courts that have considered this issue to date have held that this type of "peer to peer file sharing" violates the copyright owner's exclusive right to reproduce their copyrighted material and does not constitute a fair use.  

The Ninth Circuit Court of Appeals applied the four factor fair use analysis to address this issue.  First, the court found that the purpose and character of such a use was not transformative, since the work was merely retransmitted in a different medium.  Also, such use was found to be commercial in nature and resulted in the exploitation of copyrighted works since it saved the users the expense of purchasing the authorized copies.  The court also focussed on the fourth factor, the effect of the use on the market.  The court concluded that the internet service harmed the market for the plaintiff's copyrighted material by reducing CD sales and by interfereing with the copyright holder's attempts to charge for the same internet downloads.  

A&M Records v. Napster, 239 F.3d 1004; see also MGM v. Grokster}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the fair use doctrine permit users download MP3 files to make temporary copies of copyrighted sound recordings to "sample" the music before deciding whether to purchase the recording?},
 answer:   %{The courts that have considered this issue thus far have held that allowing users to download a full, free, and permanent copy of the copyrighted recording would be a commercial use that would adversly affect the copyright owners' market for their work. The Napster court observed that "even if sampling enhanced the audio CD sales of the recording, the benefit to the copyright owner is not a sufficient indiciation of fair use."  Further, the court held, even if the sampling benefited the copyright owner's audio CD sales, the copyright owner still enjoyed the right to develop alternative markets, such as the digital download market, and not to have such market usurped from them.

A&M Records, Inc. v. Napster, Inc., 239 F.3d 1004}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can users engage in "space shifting" in which MP3s are downloaded to listen to music the user already owns?},
 answer:   %{No.  An internet service, such as Napster, that allows a user to copy music he already owns onto the service itself in order to access the music from another location, also allows millions of other individuals to access the music.  Since this leads to the distribution of the copyrighted material to the general public, this type of space shifting would not be a fair use. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a person or company create and stream line clips of movies over the internet to video retailers to play for their customers?},
 answer:   %{Probably not.  It is not a fair use to stream such clips over the internet if the purpose is to promote the sale and rental of the videos.  Such a use infringes on the copyright owner's exclusive rights to reproduce, publicly display and distribute their work, and to create derivative works.  

A court will apply the four factor fair use analysis to the individual facts of such a case to determine whether the use was fair.  Courts have found that stream lining movie trailers for the purpose of promoting sales or rentals serves a commercial purpose and is not transformative since the use is not different than the purpose for which it was originally created. However, if the video trailer adds criticism or commentary to the original work, it is more likely that the court will consider it to be a fair use.  Courts have also found that even if the movie clip is short and therefore only uses a small portion of the original work, the aggregation of scenes may reflect the themes and tone of the film in a way that inteferes with the plaintiff's ability to evoke the same expressive values in its own previews.  With regard to the effect of the use on the market, a misleading arrangement of scenes or a low quality clip could lead to an adverse effect on the copyright owner's market.  Also, such previews could detract from sales on the copyright owner's official website.  

Video Pipeline, Inc. v. Buena Vista Home Entertainment, 192 F.Supp.2d 321}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an operator of a computer Bulletin Board Service (BBS) assert fair use as a defense to allowing a third party to use the service to post infringing copies of works to the BBS, creating a temporary copy of the work on the operator's server?},
 answer:   %{Maybe.  The California District Court has found that such a use benefits the public despite its commercial nature because it promotes the distribution of copyrighted works.  The court also found that the operator's purpose in using the work was different from that of the copyright owner's.  With regard to the nature of the copyrighted work, the court found that since the use of the work was for the purpose of facilitating the posting of the articles, the nature of the works themselves was not an important factor in the inquiry.  

Although substantial amounts of the copyrighted works were copied onto the BBS, the court found that no more was copied than was necessary to serve the website's purpose.  Finally, the court found there was a qustion of fact as to whether the use affected the potential market for the work.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the fair use doctrine permit an operator of a visual search engine -- or other Internet web site -- to "import" or provide an inline link to a copyrighted, full size image, where such importing/linking does not involve making a copy of the image? },
 answer:   %{As of now, there is no official decision with regard to this issue.  The Ninth Circuit Court of Appeals withdrew its previous decision in which it held that a search engine may not display the full size images without the copyright owner's permission because such a use infringed on the owner's exclusive right to publicly display his or her works.  In its recently-issued opinion (July 2003), the court determined that this issue did not need to be addressed, and the issue was remanded back to the lower court.
}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is inline linking and framing?},
 answer:   %{Inline linking allows an internet service to import an image from another website and then include it on the server's own website.  The user is able to click on an image and then open a new window to display the full size image, within the server's website.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a thumbnail image?},
 answer:   %{A thumbnail is a smaller, lower resolution copy of a larger image the enlargement of which would lead to a loss of clarity of the image.  }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{How do I file a DMCA counter-notice?},
 answer:   %{If you believe your material was removed because of mistake or misidentification, you can file a "counter notification" asking the service provider to put it back up.  Chilling Effects offers a <a href="http://www.chillingeffects.org/dmca/counter512.pdf">form to build your own counter-notice</a>.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Why does a web host, blogging service provider, or search engine get DMCA takedown notices?},
 answer:   %{ Many copyright claimants are making complaints under the Digital Millennium Copyright Act, Section 512(c)'s safe-harbor for hosts of "Information Residing on Systems or Networks At Direction of Users" or Section 512(d)'s safe-harbor for providers of "Information Location Tools."  These safe harbors give providers immunity from liability for users' possible copyright infringement -- if they "expeditiously" remove material when they get complaints.  Whether or not the provider would have been liable for infringement by materials it hosts or links to, it can avoid the possibility of money damages by following the DMCA's takedown procedure when it gets a notice. The person whose information was removed can file a <a href="https://lumendatabase.org/counter_notices/new">counter-notification</a> if he or she believes the complaint was erroneous. }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I post a paragraph of text on my website?},
 answer:   %{Maybe.  ...}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I post a copyrighted image on my website?},
 answer:   %{Maybe.  In order to determine whether you can post a copyrighted image on your website, a court would apply the four factor fair use analysis.  

First, it is important to determine the purpose and character of the use.  If the use is commercial in nature, rather than for nonprofit education purposes, it less likely to be considered a fair use.  To determine if it is commercial, a court would consider whether the use was exploitative and for direct profit, or if instead any commercial character was incidental.  Also, if the use is transformative and for a different purpose than the original work, it is more likely the first factor will weigh in favor of finding a fair use.  For example, in Kelly v. Arriba Soft Corporation, the court found that posting "thumbnail" images on a website was a fair use because such images served a different purpose than the original images.  

Second, the court would consider the nature of the copyrighted work.  The reproduction of a predominantly factual work is more likely to be considred a fair use than the reproduction of a highly creative one.

Third, it is important to consider the amount and substantiality of the portion of the copyrighted image used.  This inquiry looks at not only the quantity, but also on the expressive value, of the portion used.  If a large amount of the original image is copied, or if the portion copied is substantially significant to the work as a whole, it is less likely the court will find such copying to be a fair use.

Finally, the most important factor in this inquiry is the effect of the use on the potential market for the copyright owner's work.  If posting the image on the website leads to a reduction in sales of the copyrighted work or discourages people from accessing the copyright owner's website, a court is more likely to find that the use is not fair and has an adverse impact on the copyright owner's market.  

These four factors will be evaluated by a court in a factual inquiry to determine whether the posting of the image would constitute a fair use.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is section 512 of the DMCA, and what are its various provisions?},
 answer:   %{The On-Line Copyright Infringement Liability Limitation Act (OCILLA), included as section 512 of the Digital Millennium Copyright Act (DMCA), was passed in 1998.  It provides Internet Service Providers (ISPs), such as providers of DSL and dial-up Internet access, as well as other Online Service Providers (OSPs), such as search engines, with a }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trade dress?},
 answer:   %{Trade Dress is a distinctive, nonfunctional feature, which distinguishes a merchant's or manufacturer's goods or services from those of another.  The trade dress of a product involves the "total image" and can include the color of the packaging, the configuration of goods, etc...  Even the theme of a restaurant may be considered trade dress.  Examples include the packaging for Wonder Bread, the tray configuration for Healthy Choice frozen dinners, and the color scheme of Subway sub shops.  Such a broad and ambiguous definition makes trade dress very easy to manipulate.  Seeking protection against trade dress infringements can be vital to the survival of a business.

}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trademark misuse?},
 answer:   %{Trademark Misuse is a largely theoretical argument about how a trademark holder can use its rights. It would be similar to the defenses brought in copyright and patent cases, which dictate that if the owner of the intellectual property rights (e.g. a patent or copyright) over-exerts its rights (e.g forces someone to buy an unrelated product to gain acess to the protected work), then the copyright or patent holder loses its right to sue for infringement. 

Recently, the theory was employed in challenging Network Solutions' dispute policy which held that registered trademark holders had the right to have Network Solutions immediately freeze any allegedly infringing domain names until the dispute was settled. It was argued that often claims with little or no support were being alleged by registered trademark holders so as to prevent possibly infringing sites from materializing. Although the trademark holder's registration (and rights) were not cancelled, the argument that giving "extra" rights to registered trademark holders was unfair ultimately led to a change in Network Solution's dispute policy.

It is believed that the trademark misuse theory may still prove useful where a domain name owner is forced by a trademark owner to litigate or arbitrate a frivolous claim of infringement. 
}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What's wrong with removing a copyright notice?},
 answer:   %{<a href="http://www4.law.cornell.edu/uscode/17/1202.html">Section 1202</a> of the Copyright Act prohbits unauthorized removal or alteration of copyright management information, which might include a copyright notice.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is trade libel?},
 answer:   %{Trade libel is defamation against the goods or services of a company or business. For example, saying that you found a severed finger in a particular company's chili (if it isn't true).}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Do the safe harbor provisions of section 512(c) apply to instances of alleged trademark infringement?},
 answer:   %{SSection 512(c) does not pertain to instances of trademark infringement.  Sub-section (1) states, "a service provider shall not be liable for . . . infringement of <i>copyright</i> by reason of the storage at the direction of a user of material that resides on a system or network controlled or operated by or for the service provider . . ." (emphasis added).  On its face, therefore, 512(c) is not applicable to a situation in which a trademark holder gives notice to an on-line service provider (OSP) that a user is infringing his or her intellectual property rights.  However, in the absence of any caselaw on the subject, should a trademark holder bring a claim for contributory infringement, an OSP might be able to mount a valid defense by analogy to section 512(c).}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a domain name?},
 answer:   %{A domain name is a name associated with a particular computer online.  In the domain name www.chillingeffects.org, .org is the top-level domain ("TLD"), chillingeffects is the second-level domain name, and www is a subdomain.  Domain names are looked up on name servers in the DNS hierarchy to resolve them to numerical IP addresses.

A domain name registration, like a telephone directory listing, is simply a service by which the domain registry agrees to list your domain name and the corresponding IP address in its domain zone file (such as the .com zone file). The routers that forward data bits around the Internet must consult these zone files to know which machine you're using.  If the registry removes the domain name from the zone file, then routers (and users) will not be able to address mail or see your website if they use your domain name.  They can, however, still reach you by using your IP address. 

There are over 250 top level domains (like .com, .us and .uk). Each has its own procedures for handling registrations and trademark disputes. }
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Notice?},
 answer:   %{Notice is information concerning a fact, actually communicated to a person by an authorized person, or actually derived by him from a proper source.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Goodwill?},
 answer:   %{An intangible but recognized business asset which is the result of such features of an ongoing enterprise as the production or sale of reputable brand name products, a good relationship with customers and suppliers, and the standing of the business in the community.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is section 1 of the Defamation Act 1996?},
 answer:   %{ An Act to amend the law of defamation and to amend the law of limitation with respect to actions for defamation or malicious falsehood. 

[4th July 1996] 

BE IT ENACTED by the Queen's most Excellent Majesty, by and with the advice and consent of the Lords Spiritual and Temporal, and Commons, in this present Parliament assembled, and by the authority of the same, as follows:- 
 
 
  
Responsibility for publication 
Responsibility for publication.     1. - (1) In defamation proceedings a person has a defence if he shows that- 
  
  (a) he was not the author, editor or publisher of the statement complained of, 
  (b) he took reasonable care in relation to its publication, and 
  (c) he did not know, and had no reason to believe, that what he did caused or contributed to the publication of a defamatory statement. 
      (2) For this purpose "author", "editor" and "publisher" have the following meanings, which are further explained in subsection (3)- 
  
  "author" means the originator of the statement, but does not include a person who did not intend that his statement be published at all; 
  "editor" means a person having editorial or equivalent responsibility for the content of the statement or the decision to publish it; and 
  "publisher" means a commercial publisher, that is, a person whose business is issuing material to the public, or a section of the public, who issues material containing the statement in the course of that business. 
      (3) A person shall not be considered the author, editor or publisher of a statement if he is only involved- 
  
  (a) in printing, producing, distributing or selling printed material containing the statement; 
  (b) in processing, making copies of, distributing, exhibiting or selling a film or sound recording (as defined in Part I of the Copyright, Designs and Patents Act 1988) containing the statement; 
  (c) in processing, making copies of, distributing or selling any electronic medium in or on which the statement is recorded, or in operating or providing any equipment, system or service by means of which the statement is retrieved, copied, distributed or made available in electronic form; 
  (d) as the broadcaster of a live programme containing the statement in circumstances in which he has no effective control over the maker of the statement; 
  (e) as the operator of or provider of access to a communications system by means of which the statement is transmitted, or made available, by a person over whom he has no effective control.
  
      In a case not within paragraphs (a) to (e) the court may have regard to those provisions by way of analogy in deciding whether a person is to be considered the author, editor or publisher of a statement. 
      (4) Employees or agents of an author, editor or publisher are in the same position as their employer or principal to the extent that they are responsible for the content of the statement or the decision to publish it.
  
      (5) In determining for the purposes of this section whether a person took reasonable care, or had reason to believe that what he did caused or contributed to the publication of a defamatory statement, regard shall be had to- 
  
  (a) the extent of his responsibility for the content of the statement or the decision to publish it, 
  (b) the nature or circumstances of the publication, and 
  (c) the previous conduct or character of the author, editor or publisher. 
      (6) This section does not apply to any cause of action which arose before the section came into force.
  
  
 
}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "coined term"?},
 answer:   %{This is a made-up word designed specifically for use as a trademark (such as Xerox or Kodak).  It is designed solely to designate a product, so it receives the strongest protection under the law.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "coined term"? },
 answer:   %{A coined term is a made-up word, such as Kodak or Xerox, with no pre-existing use than as a trademark.  These generally receive the strongest protection under the law because they are usually not similar to other terms or descriptive of other goods.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What does "under penalty of perjury" mean?},
 answer:   %{Law.com offers a good definition of perjury: "Perjury is the the crime of intentionally lying after being duly sworn (to tell the truth) by a notary public, court clerk or other official. This false statement may be made in testimony in court, administrative hearings, depositions, answers to interrogatories, as well as by signing or acknowledging a written legal document (such as affidavit, declaration under penalty of perjury, deed, license application, tax return) known to contain false information. Although it is a crime, prosecutions for perjury are rare, because a defendant will argue he/she merely made a mistake or misunderstood."  }
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is third-party liability, also known as "secondary liability"?},
 answer:   %{The concept of third party liability refers, as the name implies, to situations in which responsibility for harm can be placed on a party in addition to the one that actually caused the injury.  The most common example comes from tort law: a customer in a grocery store drops a bottle of wine and another customer slips on the puddle and injures himself; he may bring an action for negligence against the customer who dropped the bottle and against the owner of the grocery store.  Under the common law doctrine of third-party liability, a plaintiff must show not only that an injury actually occurred, but also (in most cases) that some sort of connection existed between the third party and the person who actually caused the injury.  

As such the concept of third-party liability is often divided into two different types: contributory infringement and vicarious liability.  Typically, contributory infringement exists when the third party either assists in the commission of the act which causes the injury, or simply induces the primary party to do so commit the act which caused the injury.  Vicarious liability often requires the third party to have exerted some form of control over the primary party}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an online service provider (OSP) be held contributorily liable for acts of trademark infringement by one of its users?},
 answer:   %{Under section 512(c) of the DMCA an OSP will not be held liable for instances of <I>copyright</I> infringement so long as the OSP satisfies certain statutory requirements. However, there is no equivalent legislation pertaining to trademark infringement, and given the paucity of caselaw concerning liability of OSPs in such instances, it remains an open question as to whether or not an OSP could, or should, be held liable for acts of trademark infringement by its users. In trademark law, contributory liability exists when a manufacturer or distributor intentionally induces another party to infringe a valid trademark, or when it continues to supply products to a party that it knows, or has reason to know, is using the products to engage in trademark infringement. <I>Inwood Laboratories v. Ives Laboratories</I>, 456 U.S. 844 (1982). Lower courts have since disagreed somewhat over what exactly satisfies the "know, or has reason to know" standard. In one case, <i>Fonovisa v. Cherry Auction</i>, 76 F.3d 259 (9th Cir. 1996), the Ninth Circuit Court of Appeals held that a flea market operator could not ignore, with impunity, the actions of its vendors who were blatantly engaging in trademark infringement. In another case, <i>Gucci America, Inc. v. Hall & Associates</i>, 135 F. Supp. 2d 409 (S.D.N.Y. 2001), the District Court for the Southern District of New York refused to grant an ISP's motion to dismiss in a case involving instances of trademark infringement occurring on a subscriber's website hosted by the ISP. There the plaintiff allegedly had sent two e-mails to the ISP regarding the alleged infringement, but the ISP failed to take any action. Collectively, these few cases suggest that an OSP could be found contributorily liable for acts of trademark infringement. In any such suit, one of the main issues would be to what extent the OSP knew, or should have known, of the infringing acts? That is to say, what did the OSP do to police its service, or what should it have done? And more specifically, if the plaintiff attempted to notify the OSP of the infringing acts, what kind of notice would suffice? Under section 512 of the DMCA, the notice requirements are made quite clear. As the law stands now, however, that issue remains far less clear in the area of trademark infringement.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a service provider have to follow the safe harbor procedures?},
 answer:   %{No. An ISP may choose not to follow the DMCA takedown process, and do without the safe harbor.  If it would not be liable under pre-DMCA copyright law (for example, because it is not contributorily or vicariously liable, or because there is no underlying copyright infringement), it can still raise those same defenses if it is sued.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What does UCE stand for?},
 answer:   %{Unsolicited Commercial E-mail, also referred to as "spam."}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "actual" and "punitive" damages?},
 answer:   %{Actual damages are damages awarded to a winning party to compensate them for a proven injury or loss; damages that repay actual losses.

Punitive damages are damages awarded in addition to actual damages when the defendant acted with recklessness, malice, or deceit. Punitive damages are intended to punish and thereby deter blameworthy conduct.

(Black's Law Dictionary)}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Are website terms of use binding contracts?},
 answer:   %{The law is still not settled on so-called "click-wrap" contracts, but a court will look at how prominently the terms of use are displayed and whether you had to agree to them before you could proceed with using the website or service.  

If you never saw the terms of use, there can be no "meeting of the minds" to form a contract.  In <a href="http://cyber.law.harvard.edu/stjohns/Specht_v_Netscape.pdf" target="new">Specht v. Netscape</a>, a court found that there was no contract for a software download, where there was no proof the downloaders were on notice of or agreed to the terms.}
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{What if the letter accuses me of something I'm not doing?},
 answer:   %{If the cease-and-desist misinterprets what your website is doing, for example claiming you're "reproducing" things you just link to, you can try to send a response that clarifies the facts -- especially if the factual difference is legally relevant.  First, though, you may want to judge from the tone of the letter whether that's likely to resolve the matter, or instead just to draw more attention to you and make the requester angrier.}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the communication requirements that Section 512 imposes on OSPs, complainants, and alleged infringers?},
 answer:   %{<B>Each of the parties</B> -- the complainant, the Online Service Provider (OSP), and the alleged infringer -- has the right to communicate with the other parties.  In addition, OSPs and complainants are required to engage in certain communications in order to take advantage of the DMCA's notice-and-takedown and safe harbor provisions.   (For more information about the process see FAQ 130.)  

<B>The complainant</B> starts the Sec. 512 process by notifying the Online Service Provider (OSP) or the OSP?s agent in writing of a copyright infringement.  (See [FAQ 127 for more information about what constitutes an OSP and FAQ 450 for more information about what constitutes copyright infringement.)  Section 512(c)(3)(A)(iii) sets out the requirements for notice to OSPs.  Under this section, the complainant must specifically identify the material that is claimed to be infringing or to be subject of infringing activity and that is to be removed or access to which is to be disabled, and information reasonably sufficient to permit the service provider to locate the material. 
 
Section 512(d)(3) sets out the procedure for contacting information location tools, such as search engines.  Under Sec. 512(d), the complainant must identify the reference or link to the allegedly infringing material, and must provide enough information for the search engine to locate the link.  (For more information about the contents of notices, see FAQ 440.)  

The complainant is not required to contact the alleged infringer at any time.  [&sect; 512(h)(5).]  However, complainants who do wish to contact the infringer, or to file suit on an infringer, may use the Sec. 512(h) subpoena process to require an OSP provide its customers? identifying information to the complainant.

<B>The OSP</B> has two separate sets of communication obligations.  First, the OSP is generally required to establish policies regarding copyright infringement and repeat infringers and to inform subscribers and account holders about those policies as well as about the actions taken against repeat infringers.  [&sect; 512(i)(1)(A).]  This applies both to Sec. 512(c) ISPs and Sec. 512(d) information location tools.

Second, once an OSP receives a Section 512 takedown notice, either one, Sec. 512(c) ISPs or Sec. 512(d) information location tools, is required to notify its subscriber that it has disabled access to the allegedly infringing material.  [&sect; 512(g)(2)(A).]   

<B>A recipient</B> is not required to respond in any way to Sec. 512 notices from OSPs or complainants.  However, without a recipient response, the OSP will generally remove or disable access to the material, possibly even disabling an ISP account.  To avoid this, the recipient may file a counter-notification with the OSP, denying that the material infringes copyright. [&sect; 512(g)]  If an OSP receives a counter-notification, then the service provider must notify the complainant that it will cease disabling access in 10 business days unless the complainant obtains a court-imposed restraining order. [&sect; 512(g)(2)(C)] }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What subject matter is not copyrightable?},
 answer:   %{Copyright protects original works of authorship fixed in a tangible medium.  Copyright does not protect facts, ideas, procedures, processes, systems, methods of operation, concepts, principles, or discoveries. 17 U.S.C. }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Do you have to have a copyright notice or register your copyright in order to send a 512 C&D?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does an ISP have to respond to the complainant to tell them when the material has been removed?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Digital Millennium Copyright Act?},
 answer:   %{The DMCA, as it is known, has a number of different parts.  One part is the anticircumvention provisions, which make it illegal to "circumvent" a technological measure protecting access to or copying of a copyrighted work (see <!--GET FAQLink 12-->).  Another part gives web hosts and Internet service providers a "safe harbor" from copyright infringement claims if they implement certain notice and takedown procedures (see <!--GET FAQLink 14-->).}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{To qualify for a DMCA Safe Harbor, do ISPs need to respond to notices for takedowns of alleged P2P infringements? },
 answer:   %{Section 512 provides safe harbor protection for four classes of online service providers.  512(a) covers conduit systems that transmit and route data between users and store copies only as part of that process.  512(b) protects caching systems, which temporarily retain copies for users requesting it from its original source.  512(c) protects storage systems that allow users to store information on their networks, such as a web hosting service or a chat room.  Finally, 512(d) covers information location tools such as search engines or directories.  (See What defines a service provider under Section 512...?)

Using typical P2P file-sharing services, users store files on their computers and send them directly to each other.  The users}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Why does an ISP send DMCA notices to its subscribers for copyright owners?},
 answer:   %{Notice whether the letter came from an Internet Service Provider (ISP) and not from the copyright owner.  The Digital Millenium Copyright Act both protects ISPs from copyright liability (leaving the end user with that liability) and requires ISPs to participiate in a "takedown" process when copyright owners claim infriging use.  See the FAQs associated with this notice for more information.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{May ISPs specify the format in which they receive takedown notices?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Do DMCA 512 provisions apply to other rights such as defamation and trademark?  [link to 569 for more info about trademark]  [link to 436 for definition of word defamation]  [link to 51 for trademark]},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What can happen to an ISP if it does not take down the requested information?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{May non-US citizens use the DMCA?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the DMCA apply to non-US websites?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I send a C&D for someone else's copyrighted material?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Do search engines have to notify sites they index?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between 512(c) and (d)?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What can be kept as a trade secret?},
 answer:   %{A trade secret is information that provides a business with a competitive advantage.  The following section provides examples of circumstances where trade secret protection was approved or denied. Courts have provided trade secret protection to formulas, patterns, plans, designs, physical devices, processes, software, and }
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{What do courts consider in determining if a trade secret exists?},
 answer:   %{Courts usually consider the following three factors in determining whether you have a trade secret:

<b>(1)  <u>Is the information deemed to be a "trade secret" valuable to the business?</b></u>
Only secret information can be protected by trade secret law.  Secrecy is typically determined by evaluating whether or not the information is "generally known" or "readily ascertainable."  If the information is secret, you must consider whether the secret information is valuable to your business.  How would you rank its value?  Courts tend to find that the information is a trade secret if the information is so valuable as to significantly impact the operations of a business.   
</p><p>
<b>(2) <u>What steps have been taken to keep the information secret?</b></u>
Trade secret laws require that you have taken some action to keep your information a secret.  The security procedure taken to protect the information is often the most important evidence that the information constitutes a trade secret.  For example, courts have often found that restricting access (on a "need to know" basis) to any sensitive information is a factor that helps to meet this requirement.  Courts have also found that physical security, such as keeping written trade secret information in a locked drawer and granting very limited access to it, can meet this requirement.  Generally, holders of trade secrets develop a formal system for safeguarding their trade secret information.  Such a system can include, for example, reviewing information to be sure that the secret information is not included in documents sent to customers and competitors.   In addition, proprietary notices can be placed on all documents containing information related to trade secrets and strict confidentiality provisions can be written into all consulting, manufacturing, employment, and/or non-disclosure agreements. 
</p><p>
<b>(3)  <u>To what extent do employees and others involved in the business know about the information? What about people outside the business?</b></u>
The extent that those in your business and those outside the business have access to the information can affect a court's decision as to whether you have a legal trade secret.  Generally, courts have found the information to be public knowledge and not a trade secret if people who do not have a need to know the information have access to it.  This is especially true if many people outside the company are familiar with the information.
</p>

}
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{How is a trade secret related to a patent? },
 answer:   %{Both trade secrets and patents are forms of intellectual property that can be used to protect innovations.  Generally, the subject matter that can be protected by trade secrets is broader than that which can be protected by patents.  Trade secret protection is available for both technical information and information that does not relate to technical innovations.  Non-technical information for which trade secret protection can exist includes: business and marketing plans, and customer lists.  Patent protection is generally available for technical innovations, including a new and useful process, machine, manufacture or composition of matter.  Software and software-implemented business methods have the potential of being protected by both patents and trade secrets.  

One of the differences between patent protection and trade secret protection is that patent protection requires the protected information become available to the public (through publication of the patent application and/or patent), whereas trade secret protection requires the protected information be kept secret.  Therefore, if you patent a trade secret, once the application or patent is published, it will no longer be protected by trade secret laws.  Accordingly, you have to choose between either patent protection or trade secret protection.

Another significant difference is that patent protection can provide a broader scope and stronger form of protection.  For example, unlike trade secrets, patents can be enforced against someone who independently develops or "reverse engineers" an invention.  Also, because patents are published and are made public, they also provide "defensive" protection - by being prior art so that someone else can't obtain patent rights in the invention.

A trade secret has it's own advantages.  One significant advantage is that the term of protection for a trade secret has the potential to last forever - as long as the invention is kept a secret - whereas patents are only protected for a limited number of years (20 years from filing). Also, trade secrets can be less expensive to protect and to enforce.

In sum, the selection between patent protection and trade secret protection requires careful consideration of several factors.  In particular, it is important to consider the nature of the subject matter being protected.  Questions relevant to this decision include:  Can it be independently developed?; can it be reverse engineered?; can it be maintained as a secret?; how long will the subject matter have market value?; and does the market value support investment in patent protection/enforcement? }
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{What does },
 answer:   %{One has }
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I license my trade secret?},
 answer:   %{Trade secrets are property right.  As such, if you have a trade secret, you can license (i.e., lease) your trade secret to others.  In legal terms, the money you receive from the license is often referred to as a }
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{Do the DMCA 512 provisions apply to page-rank hijacking or sites getting higher page ranks?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does it make a difference if a link is an advertisement or just a link?
},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a complainant use the safe harbor provisions for violations of the anticircumvention provisions?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Can more than one person have trade secret rights to the same technology? },
 answer:   %{Yes, two (or more) individuals or entities can claim rights to the same trade secret on the same technology if both independently developed that technology and both keep it a secret, as long as the technology is not "generally known."}
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I protect my trade secrets from disclosure by my employees?},
 answer:   %{There are two types of legal contracts that are widely used to help businesses protect trade secrets: (1) non-disclosure agreements; and (2) non-compete agreements.  Often, these agreements are included as part of an "employee agreement' that is signed upon commencement of employment.

<b><u>(1)  NON-DISCLOSURE AGREEMENTS (NDAs)</b></u>

During the course of business, you may have to disclose your business secrets to your employees.  What happens when you have a disloyal, untrustworthy, or dishonest employee and that employee knows your secrets?  Is there anything you can do to stop the employee from telling others?

A non-disclosure agreement (NDA) is a confidentiality agreement that can be used to protect trade secrets.  Often, during the regular course of business, your secret information may be disclosed to employees or business partners.  An NDA requires that the information be kept a secret.  The provisions of the agreement require the person to keep the information confidential.  If someone has signed an NDA and uses your trade secret without your authorization, you can sue for damages and stop the violator.

<b><u>(2)  NON-COMPETE AGREEMENTS</b></u>

During the regular course of business, you may have to disclose your business secrets to your employees.  But what happens when these employees leave your company?  By requiring your employees to sign a non-compete agreement, employees must agree not to work for a direct competitor for a certain amount of time after leaving your company.  The theory behind this type of agreement is that after a certain amount of time, your trade secret will no longer be valuable because of technological changes as your business advances, and, accordingly, the technology will no longer need to be protected as a trade secret.  

It is important to be aware that courts use a "rule of reason" in deciding whether a noncompete agreement is legal.  In other words, the terms of a non-compete agreement must be reasonable as to the duration, territory, and scope of the activity.  A restraint is generally enforceable if it is fairly designed to protect the employer}
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{What does ?misappropriating? a trade secret mean?
},
 answer:   %{One has ??misappropriated? a trade secret if he or she has acquired, disclosed, or used the trade secret information without the permission of the holder, where such activities were done through improper means (e.g., the trade secret information was stolen from the holder) or in breach of an obligation of confidentiality or non-use. If you have received a letter stating that you have ?misappropriated? a trade secret (see SAMPLE LETTERS; also see TRADE SECRET LAWS), you should consult with an attorney. }
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I sell my trade secret?
},
 answer:   %{Yes, trade secrets are property rights.  As such, you can sell (i.e., assign) your trade secret to someone else. Please note, however, that courts generally prefer agreements to be in writing. You may wish to consult a lawyer in your local area to assist with writing an agreement that states the terms of the purchase.}
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a complainant need to contact the alleged infringer before sending a 512 notice to an ISP?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{If something is not authorized, does that mean that it is infringing?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "continuation"?},
 answer:   %{Applicable mainly in the US, continuations are second or subsequent applications which are subsequently filed while the original parent application is pending. Continuations must claim the same invention as the original application to gain the benefit of the parent filing date. 
}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{How can I search for foreign patents?},
 answer:   %{Several online search services are available to find foreign patents.  A collection can be found here: http://www.library.okstate.edu/patents/foreign.htm.
}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "special damages"?  When are they awarded?},
 answer:   %{"Special damages" are awards made to plaintiffs to compensate for actual monetary losses.  In a libel case, the "special damages" would be awarded to compensate for specific losses caused by the libelous speech.  The plaintiff would be required to show the specific monetary losses were caused by the libelous speech, in addition to showing that the speech was libel, in order to be awarded special damages.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between 512(a), 512(b), 512(c), and 512(d)?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Where can I find more information about the RIAA's "John Doe" lawsuits?},
 answer:   %{The Electronic Frontier Foundation (EFF) maintains an archive of papers and court filings at <a href=http://www.eff.org/IP/P2P/riaa-v-thepeople.php>http://www.eff.org/IP/P2P/riaa-v-thepeople.php</a>.}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{My ISP tells me it's been asked to turn over my name as part of a lawsuit against hundreds of "John Does" in a faraway state. What can I do?},
 answer:   %{You should probably contact a lawyer, and suggest that the lawyer take a look at arguments raised by the EFF, ACLU, and Public Citizen in one of these suits (e.g., <a href=http://www.eff.org/IP/P2P/RIAA_v_ThePeople/JohnDoe/20040202_UMG_Amicus_Memo.pdf>http://www.eff.org/IP/P2P/RIAA_v_ThePeople/JohnDoe/20040202_UMG_Amicus_Memo.pdf</a>)}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{I use file sharing software. What can I do to make sure I'm not sued by the RIAA?},
 answer:   %{The best way to protect yourself against an RIAA lawsuit is to avoid copyright infringement. First, ensure that you are not engaging in copyright infringement by removing any files from your shared directory that you do not have permission to distribute. Second, change any potentially misleading file names that might be confused with the name of an RIAA artist or song (e.g., "Madonna"). For a more detailed explanation of this process and other ideas to avoid being treated like a criminal, visit the EFF's page on the subject at <a href=http://www.eff.org/IP/P2P/howto-notgetsued.php>http://www.eff.org/IP/P2P/howto-notgetsued.php</a>.}
)

mapping[%{John Doe Anonymity}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "treble damages"?},
 answer:   %{Treble damages are damages that, by statute, are three times the amount that the fact-finder determines is owed; also termed "triple damages."}
)

mapping[%{References}] << q.id

q = RelevantQuestion.create!(
 question: %{What is non-commercial use of a trademark?  Is non-commercial use infringment of a trademark? },
 answer:   %{Non-commercial use of a trademark is generally that use which is not related to the sale of goods or services. If no funds are solicited or earned by using someone else's mark, this use is not normally infringement. 

Trademark rights protect consumers from purchasing inferior goods because of false labeling. If no goods or services are being offered, or the goods would not be confused with those of the mark owner, or if the term is being used in a literary sense, but not to label or otherwise identify the origin of other goods or services, then the term is not being used commercially. 

One example of non-commercial use is descriptive use (where the name is used to describe something, such as "He went to MacDonald's for lunch" or "She was wearing the MacDonald tartan.")}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What are "treble damages"?},
 answer:   %{Treble damages are damages that, by statute, are three times the amount that the fact-finder determines is owed; also termed "triple damages."}
)

mapping[%{Uncategorized}] << q.id

q = RelevantQuestion.create!(
 question: %{What is Section 43(a) of the Lanham Act?},
 answer:   %{The Lanham Act is the basic federal trademark and unfair competition law.  Section 43(a) (<a href="http://www.law.cornell.edu/uscode/15/1125.html">15 U.S.C. 1125(a)</a>) is intended to protect consumers and competitors against false advertising and false designations of origin.  

The law allows for suit against someone who makes false claims about its own or a competitor's products. 

<blockquote>
Sec. 1125. False designations of origin, false descriptions, and dilution forbidden

(a) Civil action

(1) Any person who, on or in connection with any goods or services, or any container for goods, uses in commerce any word, term, name, symbol, or device, or any combination thereof, or any false designation of origin, false or misleading description of fact, or false or misleading representation of fact, which--

(A) is likely to cause confusion, or to cause mistake, or to deceive as to the affiliation, connection, or association of such person with another person, or as to the origin, sponsorship, or approval of his or her goods, services, or commercial activities by another person, or

(B) in commercial advertising or promotion, misrepresents the nature, characteristics, qualities, or geographic origin of his or her or another person's goods, services, or commercial activities, shall be liable in a civil action by any person who believes that he or she is or is likely to be damaged by such act.
</blockquote>}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a mailing list archive really be held liable for allowing a spammer to post?},
 answer:   %{Unlikely.  A mailing list archive, like other online service providers hosting user-supplied content, is protected from non-intellectual property claims by CDA 230.  For intellectual property claims, the facts are unlikely to make you liable for a spammer's conduct.}
)

mapping[%{References}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the duty of confidentiality of an employee?},
 answer:   %{Confidential information  or trade secrets received during the course of an employer-employee relationship cannot be used or disclosed to the detriment of the employer during or after termination of the relationship, even if the employee and the employer had no express contract prohibiting the use or disclosure. 
However, an employee can use all the skills and knowledge he acquired during his employment, if the skills and knowledge are commonly used in the trade. 

Many states have adopted the Uniform Trade Secrets Act, which is intended to provide states with a legal framework for improved trade-secret protection. The Act contains a definition of trade secrets which is consistent with common-law definitions. Factors used to determine if information is a trade secret include:

? The extent to which the information is known outside of the employer's business.
? The extent to which the information is known by employees and others involved in the business. 
? The extent of measures taken by the employer to guard the secrecy of the information. 
? The value of the information to the employer and to competitors. 
? The amount of effort or money expended by the company in developing the information. 
? The extent to which the information could be easily or readily obtained through an independent source. 

Trade secrets need not be technical in nature. Market-related information such as information on current and future projects, as well as potential future opportunities for a firm, may constitute a trade secret.
}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a temporary restraining order?},
 answer:   %{A temporary restraining order (TRO) is an emergency order stopping a party from acting before the court can hold a full hearing.  Generally, the TRO lasts only a short time before the other party must seek a preliminary or permanent injunction.
}
)

mapping[%{Uncategorized}] << q.id

q = RelevantQuestion.create!(
 question: %{What constitutes practice of law?},
 answer:   %{The "practice of law" is generally defined as doing and performing services in a court of justice. It also includes giving legal advice and counsel, rendering a service that requires the use of legal knowledge or skill, and preparing instruments and contracts by which legal rights are secured, whether or not the matter is pending in a court. The mere holding out by a layperson or suspended attorney that he or she is practicing or is entitled to practice law constitutes the unauthorized practice of law. However, as long as services in connection with preparation for trial are not distinctively legal and remain subject to the control of the lawyer who has responsibility for the case, those performing them are not engaged in the unauthorized practice of law. Thus, for example, an attorney may contract with a legal consulting firm for assistance in handling a medical malpractice lawsuit where the firm was to contact medical experts, but did not attempt to guaranty the "delivery" of expert testimony. 
The publication of an article written by a suspended attorney in a professional journal does not constitute the unauthorized practice of law. 
Some courts hold that the practice of law does not necessarily involve charging or receiving a fee for services performed. Other courts, however, emphasize that the element of charging a fee for services is an important factor in determining whether specified conduct constitutes the practice of law.
}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a violation of a automatic stay?},
 answer:   %{When a debtor files a bankruptcy case, he is protected against actions by any creditor. All the debtor}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Can the subject of a photograph use the DMCA 512 takedown process?  },
 answer:   %{Generally, no.  Only the copyright owner or an authorized representative of the copyright owner can send a <a href="<!--GET URL Question 130-->">DMCA takedown notice</a>.  The copyright in a photograph belongs initially to the person who took the photo, not the person who is pictured.  Unless the photo subject has gotten an assignment of copyright or permission to act on behalf of the photographer, it is improper for him or her to send a DMCA takedown notice.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a complainant have to prove that they own the copyright?},
 answer:   %{[not yet answered]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does publishing serial numbers, license numbers, CD-keys, etc., constitute an infringement of the anticircumvention provisions?},
 answer:   %{[not yet answered]}
)

mapping[%{Anticircumvention (DMCA)}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the child pornography reporting requirements?},
 answer:   %{Federal law <a href="http://www.law.cornell.edu/uscode/html/uscode/18/2258A.html">18 U.S.C. § 2258A</a> requires electronic communication service providers who become aware of child pornography to report its facts or circumstances to the National Center for Missing and Exploited Children.  }
)

mapping[%{Uncategorized}] << q.id

q = RelevantQuestion.create!(
 question: %{What is child pornography?},
 answer:   %{As defined in <a href="http://www.law.cornell.edu/uscode/html/uscode18/usc_sec_18_00002256----000-.html">18 U.S.C. 2256</a>:
"child pornography" means any visual depiction, including any photograph, film, video, picture, or computer or computer-generated image or picture, whether made or produced by electronic, mechanical, or other means, of sexually explicit conduct, where?
(A) the production of such visual depiction involves the use of a minor engaging in sexually explicit conduct;
(B) such visual depiction is, or appears to be, of a minor engaging in sexually explicit conduct;
(C) such visual depiction has been created, adapted, or modified to appear that an identifiable minor is engaging in sexually explicit conduct; or
(D) such visual depiction is advertised, promoted, presented, described, or distributed in such a manner that conveys the impression that the material is or contains a visual depiction of a minor engaging in sexually explicit conduct.

Many courts apply the so-called Dost test to determine if a given image is considered to be "lascivious" under the statute.  United States v. Dost, 636 F. Supp. 828, 832 (S.D. Cal. 1986), aff'd sub nom., United States v. Wiegand, 812 F.2d 1239, 1244 (9th Cir. 1987) set forth a six factor test:
(1) whether the genitals or pubic area are the focal point of the image;
(2) whether the setting of the image is sexually suggestive (i.e., a location generally associated with sexual activity);
(3) whether the child is depicted in an unnatural pose or inappropriate attire considering her age;
(4) whether the child is fully or partially clothed, or nude;
(5) whether the image suggests sexual coyness or willingness to engage in sexual activity; and
(6) whether the image is intended or designed to elicit a sexual response in the viewer.
See Dost, 636 F. Supp. at 832.}
)

mapping[%{Uncategorized}] << q.id

q = RelevantQuestion.create!(
 question: %{Do the Section 512 Safe Harbor provisions apply to the distribution of circumvention tools such as serial numbers or to methods for disabling copyright management systems?},
 answer:   %{Section 512 creates a safe harbor from claims of "copyright infringement" for service providers who meet the statutorily-defined criteria. "Copyright infringement" is defined by Section 501 of the Copyright Act as any violation of the exclusive rights granted in sections 106 through 121 of the Act.  Copyright infringement thus does not include violations of the DMCA's Anticircumvention provisions, which are found in Section 1201 et seq. While they are unlikely to be deemed direct infringers, distributors of serial numbers may face either vicarious or contributory liability for copyright infringement.  Vicarious liability requires that the distributor have the right and ability to control the infringer's behavior and direct financial gain by the distributor.  In circumstances of serial numbers posted on free message boards of Usenet groups, the distributor likely lacks both control and financial benefit. Contributory liability requires that the distributor possess knowledge of infringing conduct and materially contribute to the infringement.  Although a distributor of serial numbers is likely aware that the numbers will be used to infringe, under Sony, if the serial numbers are capable of capable of "substantial non infringing use" contributory infringement may not be found.

The anticircumvention provisions prohibit circumvention of technological access protection systems as well as the distribution of tools that facilitate circumvention of access or copy protection systems.  The publication of serial numbers, for example, would likely constitute the distribution of a "technology, product, service, device, component, or part thereof" that facilitates circumvention of an access control.  Under ? 1201 such a tool must either be primarily designed for or produced circumvention, have limited commercial purpose other than circumvention, or be marketed for circumvention. It is unlikely, however, that the publication would constitute "copyright infringement" as defined.  


While a service provider may be under no obligation to remove material in violation of the Anticircumvention provisions in order to maintain its safe harbor protection from copyright infringement, by hosting such material the provider is exposed to potential secondary liability under Section 1201 and may therefore have an independent reason for removing the material.
}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What are some of the crimes related to child pornography?},
 answer:   %{U.S. law criminalizes knowing distribution, including by computer, receipt, reproduction, sale, and even possession of child pornography. }
)

mapping[%{Uncategorized}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a DMCA takedown mean the material taken down was infringing?},
 answer:   %{No. ISPs can take down material according to the DMCA anytime they receive a compliant notice alleging copyright infringement 

  The ISP does not have to investigate to determine whether the material was truly infringing before taking it down. The fact that someone has claimed infringement does not prove that infringement occurred -- there might be a fair use defense, or the claim might have been false or frivolous.

In order to ensure that copyright owners do not wrongly insist on the removal of materials that actually do not infringe their copyrights, the safe harbor provisions of the DMCA require service providers to notify the subscribers if their materials have been removed and to provide them with an opportunity to send a written notice to the service provider stating that the material has been wrongly removed. [512(g)] If a subscriber provides a proper "counter-notice" claiming that the material does not infringe copyrights, the service provider must then promptly notify the claiming party of the individual's objection. [512(g)(2)] If the copyright owner does not bring a lawsuit in district court within 14 days, the service provider is then required to restore the material to its location on its network. [512(g)(2)(C)]

A proper counter-notice must contain the following information:
<ol>
<li><p>The subscriber's name, address, phone number and physical or electronic signature [512(g)(3)(A)]</p></li>
<li><p>Identification of the material and its location before removal [512(g)(3)(B)]</p></li>
<li><p>A statement under penalty of perjury that the material was removed by mistake or misidentification [512(g)(3)(C)]</p></li>
<li><p>Subscriber consent to local federal court jurisdiction, or if overseas, to an appropriate judicial body. [512(g)(3)(D)]</p></li>
</ol>
If it is determined that the copyright holder misrepresented its claim regarding the infringing material, the copyright holder then becomes liable to the OSP for any damages that resulted from the improper removal of the material. [512(f)]
</ol>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the purpose and effect of a cease and desist (C&D) notice in an alleged case of trademark infringement?},
 answer:   %{If a trademark owner believes someone is infringing his or her trademark, the first thing the owner is likely to do is to write a "cease-and-desist" letter which asks the accused infringer to stop using the trademark.  If the accused infringer refuses to comply, the owner may file a lawsuit in Federal or state court.  The court may grant the plaintiff a preliminary injunction on use of the mark -- tell the infringer to stop using the trademark pending trial. 

If the owner successfully proves trademark infringement in court, the court has the power to: order a permanent injunction; order monetary payment for profit the plaintiff can prove it would have made but for defendant's use of the mark; possibly increase this payment; possibly award a monetary payment of profits the defendant made while using the mark; and possibly order the defendant to pay the plaintiff's attorney fees in egregious cases of infringement.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is WHOIS information?},
 answer:   %{WHOIS is a searchable database maintained by registries and registrars that contains information about domain name registrations in the com, net, org, edu, and ISO 3166 country code top-level domains. Also, the protocol, or set of rules, that describes the application used to access the database.

Registrants involved in malfeasance will often provide false information for their listings on WHOIS.  So will registrants concerned with privacy who do not wish to make their home addresses, telephone numbers, or email addresses public.}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the difference between plagiarism and copyright infringement?},
 answer:   %{Many people confuse the two, but copyright infringement and plagiarism are different concepts.  Plagiarism occurs when a dishonest writer, or some other person, copies another's words or ideas without attributing them to the true author.  Black's Law Dictionary 1170 (7th ed.1999).  With plagiarism, it does not matter whether the words are copyrighted }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is an "unlicensed use" of copyrighted software?},
 answer:   %{Some material protected by copyright may be distributed by "licensing" the copyrighted material to a consumer, rather than by sale of a copy.  Software, for example, is usually "licensed" to an end-user rather than "sold."  The legal rights of the end user may then be limited by the licensing terms, provided that the end user has been contractually bound to those terms. Such terms might prohibit modification, limit the distribution of modifications, etc.  Courts are still working out the tensions between licensing and copyright's first sale and fair use rights.
}
)

mapping[%{Piracy or Copyright Infringement}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the first sale doctrine mean I can re-sell computer software?},
 answer:   %{Many makers of computer software say that their software is licensed, not sold, because the user breaks a "shrinkwrap license" on the box or clicks through an end-user license agreement ("EULA") before using the software.  The legal rights of the end user may then be limited by the licensing terms, provided that the end user has been contractually bound to those terms.  EULAs may attemtp to prohibit modification, reverse engineering, or resale.  Courts are still working out the tensions between software licensing and copyright's first sale and fair use rights.
}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What constitutes a derivative work?},
 answer:   %{[not yet answered]}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean if the cease-and-desist letter I got has a copyright notice?
},
 answer:   %{Copyright can be claimed on any original expression, but some uses of copyrighted works, including use for commentary and criticism, are fair uses, not infringement.  It is highly unlikely that someone could sue successfully for the posting of a cease-and-desist notice (most notices are minimally creative; the use is for purposes of commentary and research; the amount used is necessary to the understanding; and there is no effect on a "market" for cease-and-desist letters).}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{Is a cease-and-desist letter confidential?
},
 answer:   %{There is ordinarily no expectation of privacy or confidentiality in a letter sent to an adversary.  Unless you have made a specific promise of confidentiality beforehand, such as in a protective agreement or NDA, a letter demanding confidentiality doesn't bind you.}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{Must an ISP or message board host delete postings that someone tells him/her are defamatory? Can the ISP or message board delete postings in response to a request from a third party? },
 answer:   %{No, they are not required to delete. <a href="http://www4.law.cornell.edu/uscode/47/230.html#230.c_1">47 U.S.C. sec. 230</a> gives most ISPs and message board hosts the discretion to keep postings or delete them, whichever they prefer, in response to claims by others that a posting is defamatory or libelous. Most ISPs and message board hosts also post terms of service that give them the right to delete or not delete messages as they see fit and such terms have generally been held to be enforceable under law. }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an ISP or the host of the message board or chat room be held liable for
defamatory of libelous statements made by others on the message board?},
 answer:   %{Not in the United States.  Under <a href="http://www4.law.cornell.edu/uscode/47/230.html#230.c_1">47 U.S.C. sec. 230(c)(1)</a> (CDA Sec. 230): "No provider or user of an interactive computer service shall be treated as the publisher or speaker of any information provided by another information content provider."  This provision has been uniformly interpreted by the Courts to provide complete protection against defamation or libel claims made against an ISP, message board or chat room where the statements are made by third parties.  Note that this immunity does not extend to claims made under intellectual property laws.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Do I need permission to link to someone else's site?},
 answer:   %{In general, if someone is making a website publicly available, others may freely link to it.  That open linking is what makes the web a "web." }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Who is a public figure?},
 answer:   %{.
A public figure is someone who has actively sought, in a given matter
of public interest, to influence the resolution of the matter. In
addition to the obvious public figures }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the rules about reporting on a public proceeding?},
 answer:   %{In some states, there are legal privileges protecting fair comments about public proceedings. For example, in California you have a right to make "a fair and true report in, or a communication to, a public journal, of (A) a judicial, (B) legislative, or (C) other public official proceeding, or (D) of anything said in the course thereof, or (E) of a verified charge or complaint made by any person to a public official, upon which complaint a warrant has been issued." This provision has been applied to posting on an online message board, <a href="http://www.casp.net/colt.html">Colt v. Freedom Communications, Inc.</a>, and would likely also be applied to blogs. The California privilege also extends to fair and true reports of public meetings, if the publication of the matter complained of was for the public benefit.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "fair and true report"?},
 answer:   %{A report is "fair and true" if it captures the substance, gist, or sting of the proceeding. The report need not track verbatim the underlying proceeding, but should not deviate so far as to produce a different effect on the reader.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What if I want to report on a public controversy?},
 answer:   %{Many jurisdictions recognize a "neutral reportage" privilege, which protects "accurate and disinterested reporting" about potentially libelous accusations arising in public controversies. As one court put it, "The public interest in being fully informed about controversies that often rage around sensitive issues demands that the press be afforded the freedom to report such charges without assuming responsibility for them."}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{If I write something defamatory, will a retraction help?},
 answer:   %{Some jurisdictions have retraction statutes that provide protection from defamation lawsuits if the publisher retracts the allegedly defamatory statement. For example, in California, a plaintiff who fails to demand a retraction of a statement made in a newspaper or radio or television broadcast, or who demands and receives a retraction, is limited to getting "special damages" }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What if I change the person's name?},
 answer:   %{To state a defamation claim, the person claiming defamation need not be mentioned by name }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What's the statute of limitation on libel?},
 answer:   %{Most states have a statute of limitations on libel claims, after which point the plaintiff cannot sue over the statement. For example, in California, the one-year statute of limitations starts when the statement is first published to the public. In certain circumstances, such as when the defendant cannot be identified, a plaintiff can have more time to file a claim. Most courts have rejected claims that publishing online amounts to "continuous" publication, and start the statute of limitations ticking when the claimed defamation was first published.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What are some examples of libelous and non-libelous statements?},
 answer:   %{.
The following are a couple of examples from California cases; note the law may vary from state to state.  Libelous (when false):

<ul>
        <li> Charging someone with being a communist (in 1959)</li>
        <li> Calling an attorney a "crook"</li>
        <li> Describing a woman as a call girl</li>
        <li> Accusing a minister of unethical conduct</li>

        <li> Accusing a father of violating the confidence of son</li>
</ul>

Not-libelous:

<ul>
        <li> Calling a political foe a "thief" and "liar" in chance encounter (because hyperbole in context)</li>
        <li> Calling a TV show participant a "local loser," "chicken butt" and "big skank"</li>
        <li> Calling someone a "bitch" or a "son of a bitch"</li>

        <li> Changing product code name from "<a href="http://en.wikipedia.org/wiki/Carl_Sagan">Carl Sagan</a>" to "Butt Head Astronomer" </li>
</ul>
Since libel is considered in context, do not take these examples to be
a hard and fast rule about particular phrases. Generally, the
non-libelous examples are hyperbole or opinion, while the libelous
statements are stating a defamatory fact.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a "false light" claim?},
 answer:   %{Some states allow people to sue for damages that arise when others place them in a false light. Information presented in a "false light" is portrayed as factual, but creates a false impression about the plaintiff (i.e., a photograph of plaintiffs in an article about sexual abuse, because it creates the impression that the depicted persons are victims of sexual abuse). False light claims are subject to the constitutional protections discussed above.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{How do courts look at the context of a statement?},
 answer:   %{For a blog, a court would likely start with the general tenor, setting, and format of the blog, as well as the context of the links through which the user accessed the particular entry. Next the court would look at the specific context and content of the blog entry, analyzing the extent of figurative or hyperbolic language used and the reasonable expectations of the blog's audience. 

Context is critical.  For example, it was not libel for ESPN to caption a photo "<a href="http://en.wikipedia.org/wiki/Evel_Knievel">Evel Knievel</a> proves you're never too old to be a pimp," since it was (in context) "not intended as a criminal accusation, nor was it reasonably susceptible to such a literal interpretation. Ironically, it was most likely intended as a compliment." However, it would be defamatory to falsely assert "our dad's a pimp" or to accuse your dad of "dabbling in the pimptorial arts." (Real case, but the defendant sons succeeded in a truth defense).}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Do blogs have the same constitutional protections as mainstream media?},
 answer:   %{Yes. The US Supreme Court has said that "in the context of defamation law, the rights of the institutional media are no greater and no less than those enjoyed by other individuals and organizations engaged in the same activities."}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What are private facts?},
 answer:   %{Private facts are personal details about someone that have not been disclosed to the public. A person's sexual orientation, a sex-change operation, and a private romantic encounter could all be private facts. Once publicly disclosed by that person, however, they move into the public domain.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I be sued for publishing somebody else's private facts?},
 answer:   %{Some jurisdictions allow lawsuits for the publication of private facts. In California, for example, the elements are (1) public disclosure; (2) of a private fact; (3) that is offensive to a reasonable person; and (4) which is not a legitimate matter of public concern. Publication on a blog would generally be considered public disclosure. However, if a private fact is deemed "newsworthy," it may be legal to print it even if it might be considered "offensive to a reasonable person."}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is offensive to a reasonable person?},
 answer:   %{To state a claim, the plaintiff must show that the matter made public was one that would be offensive and objectionable to a reasonable person of ordinary sensibilities. For example, disclosing that the plaintiff returned $240,000 he found on the street was held not to be offensive, but the publication of an "upskirt" photo would likely be found to be offensive to a reasonable person.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{How do I know if a private fact is "newsworthy"?},
 answer:   %{A private fact is newsworthy if some reasonable members of the community could entertain a legitimate interest in it. Courts generally recognize that the public has a legitimate interest in almost all recent events, even if it involves private information about participants, as well as a legitimate interest in the private lives of prominent or notorious figures (such as actors, actresses, professional athletes, public officers, noted inventors, or war heroes). Newsworthiness is not limited to reports of current events, but extends to articles for the purposes of education, amusement, or enlightenment. However, a court may look at whether the private fact is pertinent to an otherwise newsworthy story.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "intrusion into seclusion"?},
 answer:   %{Intrusion into seclusion occurs when you intrude upon the solitude or seclusion of another person or his private affairs or concerns, if the intrusion would be highly offensive to a reasonable person. It generally comes up in the context of paparazzi photographing celebrities, but covers any reasonable expectation of privacy that is intruded upon. If the person intruded upon gave you consent to do it - i.e., gave you permission to take his picture or write about him - then you have a defense against this claim. Interception of an electronic communication (i.e., an email or IM chat) can raise additional legal issues, such as federal wiretap laws.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{I found something interesting on someone else's blog. May I quote it?},
 answer:   %{Yes. Short quotations will usually be fair use, not copyright infringement. The Copyright Act says that "fair use...for purposes such as criticism, comment, news reporting, teaching (including multiple copies for classroom use), scholarship, or research, is not an infringement of copyright." So if you are commenting on or criticizing an item someone else has posted, you have a fair use right to quote. The law favors "transformative" uses }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is fair use?},
 answer:   %{.
There are no hard and fast rules for fair use (and anyone who tells
you that a set number of words or percentage of a work is "fair" is
talking about guidelines, not the law).  The Copyright Act sets out
four factors for courts to look at (<a href="http://www4.law.cornell.edu/uscode/17/107.html">17 U.S.C. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{May I freely copy from federal government documents?},
 answer:   %{Yes. Works produced by the US government, or any government agency or person acting in a government capacity, are in the public domain. So are the texts of legal cases and statutes from state or federal government. Private contractors working for the government, however, can license or transfer copyrights to the US government, and those copyrights remain enforceable.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Am I free to copy elements of someone else's website verbatim?},
 answer:   %{No. While you are free to report the facts and ideas embodied in another person's article or web page, copyright protects the expression }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{How does a Creative Commons license help?},
 answer:   %{<a href="http://www.creativecommons.org">Creative Commons</a> licenses provide a standard way for authors to declare their works "some rights reserved" (instead of "all rights"). If the source you're quoting has a Creative Commons license or public domain dedication, you may have extra rights to use the content. Licenses don't trump fair use, but if you want to do more than fair use allows, look at the terms of the license to see what it permits and what, if anything, it requires you to do in return. The <a href="http://creativecommons.org/licenses/by/2.0/">attribution license</a>, for example, lets you copy, distribute, and display a work so long as you name the original author.  <a href="http://creativecommons.org/licenses/by-sa/2.0/">Share-alike</a> lets you make derivative works so long as you use the same license for your re-mix. A work in the public domain is no longer under copyright, so you can use as much as you want in any way you like.
}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{I want to complain about a company. Can I use their name and logo?},
 answer:   %{Yes. While trademark law prevents you from using someone else's trademark to sell your competing products (you can't make and sell your own "Rolex" watches or name your blog "Newsweek"), it doesn't stop you from using the trademark to refer to the trademark owner or its products (offering repair services for Rolex watches or criticizing Newsweek's editorial decisions). That kind of use, known as "nominative fair use," is permitted if using the trademark is necessary to identify the products, services, or company you're talking about, and you don't use the mark to suggest the company endorses you. In general, this means you can use the company name in your review so people know which company or product you're complaining about. You can even use the trademark in a domain name (like walmartsucks.com), so long as it's clear that you're not claiming to be or speak for the company.

Since trademark law is designed to protect against consumer confusion, non-commercial uses are even more likely to be fair. Be aware that advertising may give a "commercial" character to your site, and some courts have even gone so far as to say that links to commercial sites makes a site commercial. (See <a href="http://www.webgripesites.com/cites/peta_v_doughney.html">PETA v. Doughney</a>)}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I use a trademark in my blog's name or in the title of a blog post?},
 answer:   %{Yes, if it is relevant to the subject of your discussion and does not confuse people into thinking the trademark holder endorses your content. Courts have found that non-misleading use of trademarks in URLs and domain names of critical websites is fair. (Bally Total Fitness Holding Corp. v. Faber, URL http://www.compupix.com/ballysucks; Bosley Medical Institute v. Kremer, domain name www.bosleymedical.com). Companies can get particularly annoyed about these uses because they may make your post appear in search results relating to the company, but that doesn't give them a right to stop you.

Sometimes, you might use a trademark without even knowing someone claims it as a trademark. That is permitted as long as you're not making commercial use in the same category of goods or services for which the trademark applies. Anyone can sell diesel fuel even though one company has trademarked DIESEL for jeans. Only holders of "famous" trademarks, like CocaCola, can stop use in all categories, but even they can't block non-commercial uses of their marks.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a right of publicity claim?},
 answer:   %{.
The right of publicity is a claim that you have used someone's name or likeness to your commercial advantage without consent and resulting in injury. The plaintiff generally must prove that you're using their image or likeness for advertising or other solicitations. Freedom of speech rights protect your use of a public figure's name and likeness in a truthful way, but you can still be liable if a court determines that your use implied a false endorsement. Here are a few examples of cases where the right of publicity was at odds with the Constitution. 
<ul>
        <li> 
A newspaper's 900 number survey to determine the favorite <a href="http://en.wikipedia.org/wiki/New_Kids_On_The_Block">New Kid on the Block</a> was found to be a constitutionally protected use of the band member's name</li>
        <li> A newspaper's sale of a poster reproduction of its front page depicting <a href="http://en.wikipedia.org/wiki/Joe_Montana">Joe Montana</a> was determined to merit protection under the First Amendment</li>
        <li> A commercial featuring a robot resembling game show hostess <a href="http://en.wikipedia.org/wiki/Vanna_White">Vanna White</a> was found to infringe her right of publicity</li>
</ul>}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a statement of verifiable fact?},
 answer:   %{    A statement of verifiable fact is a statement that conveys a provably false factual assertion, such as someone has committed murder or has cheated on his spouse. To illustrate this point, consider the following excerpt from a court (<a href="http://www.casp.net/felice.html">Vogel v. Felice</a>) considering the alleged defamatory statement that plaintiffs were the top-ranking 'Dumb Asses' on defendant's list of "Top Ten Dumb Asses":

<blockquote><p>A statement that the plaintiff is a "Dumb Ass," even first among "Dumb Asses," communicates no factual proposition susceptible of proof or refutation. It is true that "dumb" by itself can convey the relatively concrete meaning "lacking in intelligence." Even so, depending on context, it may convey a lack less of objectively assayable mental function than of such imponderable and debatable virtues as judgment or wisdom. Here defendant did not use "dumb" in isolation, but as part of the idiomatic phrase, "dumb ass." When applied to a whole human being, the term "ass" is a general expression of contempt essentially devoid of factual content. Adding the word "dumb" merely converts "contemptible person" to "contemptible fool." Plaintiffs were justifiably insulted by this epithet, but they failed entirely to show how it could be found to convey a provable factual proposition. ... If the meaning conveyed cannot by its nature be proved false, it cannot support a libel claim.</p></blockquote>

    This California case also rejected a claim that the defendant linked the plaintiffs' names to certain web addresses with objectionable addresses (i.e. www.satan.com), noting "merely linking a plaintiff's name to the word "satan" conveys nothing more than the author's opinion that there is something devilish or evil about the plaintiff." 

}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{Why does a search engine get DMCA takedown notices for materials in its search listings?},
 answer:   %{Many copyright claimants are making complaints under the Digital Millennium Copyright Act, Section 512(d), a safe-harbor for providers of "information location tools." These safe harbors give providers immunity from liability for users' possible copyright infringement -- if they "expeditiously" remove material when they get complaints.  Whether or not the provider would have been liable for infringement by users' materials it links to, the provider can avoid the possibility of a lawsuit for money damages by following the DMCA's takedown procedure when it gets a complaint. The person whose information was removed can file a counter-notification if he or she believes the complaint was erroneous. 

<blockquote><!--GET display Question 129-->
<!--GET display Question 440-->
<!--GET display Question 588-->
<!--GET display Question 870--></blockquote>


For more information on the DMCA Safe Harbors, see the FAQs on <!--GET FAQLink 14-->.  For more information on Copyright and defenses to copyright infringement, see <!--GET FAQLink 5-->. }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Why does a web host or blogging service provider get DMCA takedown notices?},
 answer:   %{Many copyright claimants are making complaints under the Digital Millennium Copyright Act, Section 512(c)m a safe-harbor for hosts of "Information Residing on Systems or Networks At Direction of Users." This safe harbors give providers immunity from liability for users' possible copyright infringement -- if they "expeditiously" remove material when they get complaints.  Whether or not the provider would have been liable for infringement by materials its users post, the provider can avoid the possibility of a lawsuit for money damages by following the DMCA's takedown procedure when it gets a complaint. The person whose information was removed can file a counter-notification if he or she believes the complaint was erroneous. 
<blockquote><!--GET display Question 129-->
<!--GET display Question 440-->
<!--GET display Question 588-->
<!--GET display Question 870--></blockquote>

For more information on the DMCA Safe Harbors, see the FAQs on <!--GET FAQLink 14-->.  For more information on Copyright and defenses to copyright infringement, see <!--GET FAQLink 5-->. }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is 35 U.S.C. 273?},
 answer:   %{35 U.S.C. 273 Defense to infringement based on earlier inventor.

(a) DEFINITIONS.- For purposes of this section-

(1) the terms "commercially used" and "commercial use" mean use of a method in the United States, so long as such use is in connection with an internal commercial use or an actual arm's-length sale or other arm's-length commercial transfer of a useful end result, whether or not the subject matter at issue is accessible to or otherwise known to the public, except that the subject matter for which commercial marketing or use is subject to a premarketing regulatory review period during which the safety or efficacy of the subject matter is established, including any period specified in section 156(g), shall be deemed "commercially used" and in "commercial use" during such regulatory review period;

(2) in the case of activities performed by a nonprofit research laboratory, or nonprofit entity such as a university, research center, or hospital, a use for which the public is the intended beneficiary shall be considered to be a use described in paragraph (1), except that the use-

(A) may be asserted as a defense under this section only for continued use by and in the laboratory or nonprofit entity; and

(B) may not be asserted as a defense with respect to any subsequent commercialization or use outside such laboratory or nonprofit entity;

(3) the term "method" means a method of doing or conducting business; and

(4) the "effective filing date" of a patent is the earlier of the actual filing date of the application for the patent or the filing date of any earlier United States, foreign, or international application to which the subject matter at issue is entitled under section 119, 120, or 365 of this title.

(b) DEFENSE TO INFRINGEMENT.-

(1) IN GENERAL.- It shall be a defense to an action for infringement under section 271 of this title with respect to any subject matter that would otherwise infringe one or more claims for a method in the patent being asserted against a person, if such person had, acting in good faith, actually reduced the subject matter to practice at least 1 year before the effective filing date of such patent, and commercially used the subject matter before the effective filing date of such patent.

(2) EXHAUSTION OF RIGHT.- The sale or other disposition of a useful end product produced by a patented method, by a person entitled to assert a defense under this section with respect to that useful end result shall exhaust the patent owner's rights under the patent to the extent such rights would have been exhausted had such sale or other disposition been made by the patent owner.

(3) LIMITATIONS AND QUALIFICATIONS OF DEFENSE.- The defense to infringement under this section is subject to the following:

(A) PATENT.- A person may not assert the defense under this section unless the invention for which the defense is asserted is for a method.

(B) DERIVATION.- A person may not assert the defense under this section if the subject matter on which the defense is based was derived from the patentee or persons in privity with the patentee.

(C) NOT A GENERAL LICENSE.- The defense asserted by a person under this section is not a general license under all claims of the patent at issue, but extends only to the specific subject matter claimed in the patent with respect to which the person can assert a defense under this chapter, except that the defense shall also extend to variations in the quantity or volume of use of the claimed subject matter, and to improvements in the claimed subject matter that do not infringe additional specifically claimed subject matter of the patent.

(4) BURDEN OF PROOF.- A person asserting the defense under this section shall have the burden of establishing the defense by clear and convincing evidence.

(5) ABANDONMENT OF USE.- A person who has abandoned commercial use of subject matter may not rely on activities performed before the date of such abandonment in establishing a defense under this section with respect to actions taken after the date of such abandonment.

(6) PERSONAL DEFENSE.- The defense under this section may be asserted only by the person who performed the acts necessary to establish the defense and, except for any transfer to the patent owner, the right to assert the defense shall not be licensed or assigned or transferred to another person except as an ancillary and subordinate part of a good faith assignment or transfer for other reasons of the entire enterprise or line of business to which the defense relates.

(7) LIMITATION ON SITES.- A defense under this section, when acquired as part of a good faith assignment or transfer of an entire enterprise or line of business to which the defense relates, may only be asserted for uses at sites where the subject matter that would otherwise infringe one or more of the claims is in use before the later of the effective filing date of the patent or the date of the assignment or transfer of such enterprise or line of business.

(8) UNSUCCESSFUL ASSERTION OF DEFENSE.- If the defense under this section is pleaded by a person who is found to infringe the patent and who subsequently fails to demonstrate a reasonable basis for asserting the defense, the court shall find the case exceptional for the purpose of awarding attorney fees under section 285 of this title.

(9) INVALIDITY.- A patent shall not be deemed to be invalid under section 102 or 103 of this title solely because a defense is raised or established under this section.

(Added Nov. 29, 1999, Public Law 106-113, sec. 1000(a)(9), 113 Stat. 1501A-555 (S. 1948 sec. 4302).)


}
)

mapping[%{Patent}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the "first sale" doctrine?},
 answer:   %{First sale is a doctrine in copyright law saying the owner of a particular copy of a copyrighted work has the right to sell, lend, or transfer that copy.  In other words, the copyright holder's rights over a physical copy of a work end with the "first sale."  The doctrine is codified in the Copyright Act, <a href="http://www4.law.cornell.edu/uscode/17/109.html">17 U.S.C. 109</a>.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Am I free to copy the content from someone else's website verbatim?},
 answer:   %{No.  While you are free to report the facts and ideas embodied in another person's article or web page, you shouldn't copy the entire page unless you can assert a fair use defense. Copyright does not protect facts or ideas, but it can protect the particular way someone has expressed them. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Do I need permission from the copyright holder to make fair use?},
 answer:   %{No.  If your use is fair, it is not an infringement of copyright -- even if it is without the authorization of the copyright holder.  Indeed, fair use is especially important to  protect uses a copyright holder would not approve, such as criticism or parodies. See <a href=&quot;http://straylight.law.cornell.edu/supct/html/92-1292.ZS.html&quot;>Campbell v. Acuff-Rose Music, 510 US 569 (1994)</a>.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Why are they telling me that they monitor the internet for their mark?},
 answer:   %{A person can gain rights in a trademark merely by using it. If the mark is not an outright adoption of the original mark, but merely close enough to it so that the question as to whether or not the first mark has been infringed is no longer an open-and-shut issue, the second user can sometimes get rights in the mark just because the second user used the mark, and the first user never objected to it. This is called the "unchallenged use" doctrine. If your site has been up and running for a while, and there has been a significant length of time between you using the mark and them contacting you about it, that can be a powerful argument in your favor that in fact your use of the mark does not infringe theirs. For this reason, a Cease and Desist letter will often have a statement in it to the effect of "We found about about what you are doing as soon as was reasonable."}
)

mapping[%{Domain Names and Trademarks}] << q.id

q = RelevantQuestion.create!(
 question: %{What's this about "violent content"?},
 answer:   %{We're not sure either.  Chilling Effects knows of no law against depictions of violence toward imaginary creatures.}
)

mapping[%{Bookmarks}] << q.id

q = RelevantQuestion.create!(
 question: %{Why does a user-generated content site get DMCA takedown notices for links users have posted?},
 answer:   %{Many copyright claimants are making complaints under the Digital Millennium Copyright Act, Section 512(d), a safe-harbor for providers of "information location tools." These safe harbors give providers immunity from liability for users' possible copyright infringement -- if they "expeditiously" remove material when they get complaints.  Whether or not the provider would have been liable for infringement by users' materials it links to, the provider can avoid the possibility of a lawsuit for money damages by following the DMCA's takedown procedure when it gets a complaint. The person whose information was removed can file a counter-notification if he or she believes the complaint was erroneous. 

<blockquote><!--GET display Question 129-->
<!--GET display Question 440-->
<!--GET display Question 588-->
<!--GET display Question 870--></blockquote>


For more information on the DMCA Safe Harbors, see the FAQs on <!--GET FAQLink 14-->.  For more information on Copyright and defenses to copyright infringement, see <!--GET FAQLink 5-->. }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the privacy torts?},
 answer:   %{Much privacy law is state law, and may differ from state to state.  As general categories, states may recognize interests in: 
<li>  unreasonable intrusion upon the seclusion of another;
<li>  appropriation of the other's name or likeness;
<li>  unreasonable publicity given to the other's private life; and
<li>  publicity that unreasonably places the other in a false light before the public.
(from the Second Restatement of Torts, ? 652A)}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a valid copyright license?},
 answer:   %{A valid license is an agreement where the copyright owner retains his or her ownership of the rights involved, but allows a third party to exercise some or all of those rights without fear of a copyright infringement suit.  A license is preferred over an assignment of rights where the copyright holder wishes to maintain some ownership over the rights, or wishes to exercise continuing control over how the third party uses the copyright holder's rights.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Does copyright protect techniques or methods?},
 answer:   %{No.  Copyright protects only expression, not ideas. So while copyright might protect one author's <i>description</i> of a bookkeeping method, it does not prevent others from using the method or copying the forms needed to use it.  

This "idea/expression dichotomy" is spelled out in part in the Copyright Act's Section <a href="http://www4.law.cornell.edu/uscode/17/102.html">102(b)</a>: 
<blockquote>"In no case does copyright protection for an original work of authorship extend to any idea, procedure, process, system, method of operation, concept, principle, or discovery, regardless of the form in which it is described, explained, illustrated, or embodied in such work."</blockquote>}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Universal Copyright Convention (UCC)?},
 answer:   %{The Universal Copyright Convention (UCC), adopted at Geneva in 1952, is one of the two principal international conventions protecting copyright; the other is the Berne Convention.

The UCC was developed by United Nations Educational, Scientific and Cultural Organization as an alternative to the Berne Convention for those states which disagreed with aspects of the Berne Convention, but still wished to participate in some form of multilateral copyright protection.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Berne Convention for the Protection of Literary and Artistic Works?},
 answer:   %{The Berne Convention for the Protection of Literary and Artistic Works, usually known as the Berne Convention, is an international agreement about copyright, which was first adopted in Berne, Switzerland in 1886. It was developed at the instigation of Victor Hugo, and was thus influenced by the French "right of the author" (droit d'auteur), which contrasts with the Anglo-Saxon concept of "copyright", which has only been concerned with economic protection.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the World Intellectual Property Organization (},
 answer:   %{The World Intellectual Property Organization (WIPO) is one of the specialized agencies of the United Nations. WIPO was created in 1967 with the stated purpose of encouraging creative activity and promoting the protection of intellectual property throughout the world. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a patent?},
 answer:   %{A patent is a set of exclusive rights granted by a state to a patentee (the inventor or assignee) for a fixed period of time in exchange for the regulated, public disclosure of certain details of a device, method, process or composition of matter (substance) (known as an invention) which is new, inventive, and useful or industrially applicable.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "proprietary" material?},
 answer:   %{"Proprietary" indicates that a party, or proprietor, exercises private ownership, control or use over an item of property, usually to the exclusion of other parties.

Where a party, holds or claims proprietary interests in relation to certain types of property (eg. a creative literary work, or software), that property may also be the subject of intellectual property law (eg. copyright or patents).}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a civil lawsuit?},
 answer:   %{In a civil lawsuit, the victim brings a case for money damages against the offender or a third party for causing physical or emotional injuries. Regardless of the outcome of any criminal prosecution, or even if there was no prosecution, crime victims can file civil lawsuits against offenders and other responsible parties. The person who starts the lawsuit is called the plaintiff,and the person or entity against whom the case is brought is called the defendant. Unlike a criminal case, in which the central question is whether the offender is guilty of the crime, in a civil lawsuit, the question is whether an offender or a third party is responsible for the injuries suffered

In a civil suit, unlike a criminal prosecution, the plaintiff is responsible for the cost of litigation. Most attorneys handle victim cases on a contingency basis, which means that the attorney fee is deducted from the final award. This allows individuals to have access to the civil justice system without the need to finance the case themselves. If the case is not successful, the victim usually pays nothing. In a civil suit, the attorney directly represents the victim}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{what is criminal prosecution?},
 answer:   %{A criminal prosecution is a legal action brought by the state against an individual or group of individuals for violating state criminal laws.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What are screenshots, and is using them copyright infringement?},
 answer:   %{Screen shots or screen dumps are still images taken from computer programs. Screen shots are often used in training materials to explain how to use a computer program. Screen shots are protected by copyright law if the original work is protected.  This is due to the fact that screenshots are viewed as derivative works.  

The US Copyright Act of 1976, Section 101, says: "A derivative work is a work based upon one or more preexisting works, such as a translation, musical arrangement, dramatization, fictionalization, motion picture version, sound recording, art reproduction, abridgment, condensation, or any other form in which a work may be recast, transformed, or adapted. A work consisting of editorial revisions, annotations, elaborations, or other modifications which, as a whole, represent an original work of authorship, is a "derivative work."}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is penalty of perjury?},
 answer:   %{Perjury is the act of lying or making verifiably false statements on a material matter under oath or affirmation in a court of law or in any of various sworn statements in writing. Perjury is a crime because the witness has sworn to tell the truth and, for the credibility of the court, witness testimony must be relied on as being truthful.  The rules for perjury apply when a person has made a statement under penalty of perjury, even if the person has not been sworn or affirmed as a witness before an appropriate official.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is commercial reproduction of copyrighted materials?},
 answer:   %{Commercial reproduction is reproduction of multiple copies of copyrighted materials, in whole or in part, for the purposes of commercial redistribution. The permission granting process of copyrighted materials helps ensure individuals/organizations wishing to reproduce such materials for commercial purposes have access to the most accurate, up-to-date versions.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What are statutory damages?},
 answer:   %{A copyright owner can only sue for infringement on a work whose copyright was registered with the Copyright Office, and can get statutory damages and attorney's fees only if the copyright registration was filed before infringement or within three months of first publication. (17 U.S.C. 411 and 412) (<a href="http://www4.law.cornell.edu/uscode/17/411.html" target="new">17 U.S.C. 411</a> and <a href="http://www4.law.cornell.edu/uscode/17/412.html" target="new">412</a>)

A copyright owner may avoid proving actual damage by electing a statutory damage recovery of up to $30,000 or, where the court determines that the infringement occurred willfully, up to $150,000. The actual amount will be based upon what the court in its discretion considers just. (17 U.S.C. 504).  (<a href="http://www4.law.cornell.edu/uscode/17/504.html" target="new">17 U.S.C. 504</a>)  }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What are statutory damages?},
 answer:   %{A copyright owner can only sue for infringement on a work whose copyright was registered with the Copyright Office, and can get statutory damages and attorney's fees only if the copyright registration was filed before infringement or within three months of first publication. (17 U.S.C. 411 and 412) (<a href="http://www4.law.cornell.edu/uscode/17/411.html" target="new">17 U.S.C. 411</a> and <a href="http://www4.law.cornell.edu/uscode/17/412.html" target="new">412</a>)

A copyright owner may avoid proving actual damage by electing a statutory damage recovery of up to $30,000 or, where the court determines that the infringement occurred willfully, up to $150,000. The actual amount will be based upon what the court in its discretion considers just. (17 U.S.C. 504).  (<a href="http://www4.law.cornell.edu/uscode/17/504.html" target="new">17 U.S.C. 504</a>)  }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the purpose of the fair use defense? },
 answer:   %{There is no easy answer to this question. However, one way to approach the question is to examine the purposes of the copyright laws.  

The clause of the Constitution that gives Congress the power to enact copyright laws indicates that the purpose of the given power is to "promote the progress of science and the useful arts" by allowing authors to secure the exclusive rights in their works for "limited times." Thus, many see the Constitutional scheme behind copyright as a kind of balance between (1) forming incentives for authors to create new works by giving them rights that will allow them to make money from their works, and (2) limiting the rights so that the works themselves are useful to the public and in turn advance the "progress of science and the useful arts."  

Fair use fits into this scheme by giving the public the right to use copyrighted works in certain situations even though the author has exclusive rights. That is, in some circumstances, such as certain uses involving scholarship or research, the "progress" referred to in the Constitution is best promoted and the public is best served by allowing an unauthorized use of the copyrighted work. These uses are deemed fair because they are consistent with the power given to Congress to enact copyright laws. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Where is the fair use doctrine codified? },
 answer:   %{The fair use doctrine was originally a judge-made doctrine embodied in case law.  See Folsom v. Marsh, 9 F.Cas. 342 (1841).   Congress later codified it at Title 17 of the United States Code, Section 107.   

This section provides:  

Section 107. Limitations on exclusive rights: Fair use  

Notwithstanding the provisions of sections 106 and 106A [setting forth copyright owners' exclusive rights and visual artists' artistic rights], the fair use of a copyrighted work, including such use by reproduction in copies or phonorecords or by any other means specified by that section, for purposes such as criticism, comment, news reporting, teaching (including multiple copies for classroom use), scholarship, or research, is not an infringement of copyright. In determining whether the use made of a work in any particular case is a fair use the factors to be considered shall include }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What types of uses does the fair use doctrine protect? },
 answer:   %{The language used by Congress in Title 17, Section 107 specifically lists }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Do I need permission from the copyright holder to make fair use? },
 answer:   %{No. If your use is fair, it is not an infringement of copyright -- even if it is without the authorization of the copyright holder. Indeed, fair use is especially important to protect uses a copyright holder would not approve, such as criticism or parodies. See Campbell v. Acuff-Rose Music, 510 US 569 (1994).}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I use fair use to force a copyright holder to turn over her or his copyrighted work to me so that I can copy it and use it?},
 answer:   %{No. Fair use is a defense to a claim of infringement. Therefore, someone who wishes to make a use of the copyrighted work of another cannot force the copyright holder to turn over the work, even if the desired use would be considered fair by the courts. In such a case, the user must find a way to make the use, and then can invoke the fair use defense if she or he is sued for infringement by the copyright holder. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Suppose the owner of a copyrighted work displays this work on her or his website and places technological barriers on the work that prevent me from copying it. Does the fair use doctrine require the owner of such copyrighted work to remove those technological barriers if I can prove that my copying would be a fair use?},
 answer:   %{No. Fair use provides a defense to a claim of copyright infringement, but (according to most courts, at least) does not provide the would-be copier with the affirmative right (or ability) to copy. That is, you cannot force a copyright holder to give you copies of a work or allow you to make copies of the work. Under current copyright law, it is perfectly lawful for a copyright holder to use technological barriers to prevent others from making copies of her/his work. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{If the owner of a copyrighted work that is displayed on a website uses technological measures to prevent me from copying the work onto my website, but my copying would be a fair use, can I use technological measures to circumvent the copy protection and make the copy anyway?},
 answer:   %{Yes. Under the current copyright laws, it is lawful to circumvent technological copyright protection systems in order to make a copy. Then, if the copyright holder sues you for making the copies, and your fair use defense is successful, you are in the clear. But here's the catch: It is UNLAWFUL for someone to TRAFFIC IN technology that can be used to circumvent technological copyright protection systems. Therefore, unless you can circumvent the copyright holder's protection yourself, it is unlikely that you will be able to find the technology you need elsewhere. Note that it is also UNLAWFUL for you to circumvent ACCESS control technologies. See Chapter 12 of the Copyright Act, particularly section 1201. For more information on the anticircumvention provisions, see the Chilling Effects topic Anticircumvention (DMCA). }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Is my parody of another's copyrighted work protected as a fair use?},
 answer:   %{It is likely that a bona fide parody, as opposed to satire, that does not usurp the market for plaintiff's work or unfairly free ride on plaintiff's work will be protected as a fair use.  See Campbell v. Acuff-Rose Music, 510 US 569 (1994). Courts have held that the fair use defense can protect a parody of a copyrighted work from an infringement claim.  However, that does not necessarily mean that all parodies will be protected. In the case of a parody where the defendant raises a fair use defense, the courts will run through the four part fair use analysis just as they would with any other fair use test. [See above for the four part test].  

While it is problematic to try to predict what a court will decide in any fair use case, it is likely that in the case of a parody the court will focus on the fourth factor of the inquiry, which requires the court to ask what effect the parody has on the potential market for the copyrighted work. If the parody usurps the market for the copyrighted work, then there is an increased chance that the court will find that the use is not fair. If the parody dampens the market for the copyrighted work as a result of its implicit criticism of the work, such a negative effect on the market does not render such use unfair. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{If I am engaged in research, educational, or academic pursuits, does the fair use doctrine permit me to copy articles from a journal or periodical?},
 answer:   %{As mentioned above, it is hard to predict what a court will do when presented with a fair use defense. However, in this case the answer depends in part on your purposes in copying. If you intend to archive the copies, the answer is probably no, while if you intend to use the copies in classroom instruction (without charging for the copies), the use may be fair.  

In 1994 the Second Circuit Court of Appeals held that it was not a fair use for research scientists at Texaco to photocopy articles from various scientific and technical journals. Texaco argued, on behalf of its scientists, that the use was for the purpose of research, and therefore was fair under Section 107. But the court was not convinced. In reaching its decision, the court in Texaco ran through the four factor fair use analysis (see generally, what types of uses does the fair use doctrine protect? and introduction to this Chilling Effects topic). The court found that three of the four factors weighed against Texaco, and focused much of its opinion on the fourth factor, deciding that Texaco's use would have a significant impact on the potential market for the journal articles. Thus, in order to make copies of the articles, the research scientists at Texaco had to either pay for them or get express permission from the publishers.  See American Geophysical Union v. Texaco Inc., 60 F.3d 913 (2d Cir. 1994).  

Further, use of another's work for classroom instruction purposes may be protected under a separate provision of the Copyright Act. Section 110 of the Copyright Act contains exemptions that provide nonprofit educational institutions the limited right to use copyrighted materials in face-to-face classroom settings. This section provides: "Notwithstanding the provisions of section 106, the following are not infringements of copyright: (1) performance or display of a work by instructors or pupils in the course of face-to-face teaching activities of a nonprofit educational institution, in a classroom or similar place devoted to instruction . . . ."  

Furthermore, the recently enacted "Technology, Education, and Copyright Harmonization Act" -- the TEACH Act -- amends Section 110 to exempt certain uses of copyrighted works in the context of distance education (beyond the context of face-to-face teaching). The TEACH Act sets forth in detail the terms and conditions on which nonprofit educational institutions may use copyrighted works in the context of distance education (such as via websites or other digital means) without permission. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can I copy an entire news article from a commercial news web site and post the article on my web site?},
 answer:   %{The fair use doctrine, as currently interpreted by the courts, probably would not entitle you to do so. Even though news items are factual and facts themselves are not protected by copyright, an entire news article itself is expression protected by copyright.  

A court would apply the four factor fair use analysis to determine whether such a use is fair. In Los Angeles Times v. Free Republic, the court found that such a use was minimally -- or not at all -- transformative, since the article ultimately served the same purpose as the original copyrighted work. The initial posting of the article was a verbatim copy of the original with no added commentary or criticism and therefore did not transform the work at all. Although it is often a fair use to copy excerpts of a copyrighted work for the purpose of criticism or commentary, the copying may not exceed the extent necessary to serve that purpose. In this case, the court found that only a summary and not a complete verbatim copy of the work was necessary for the purpose of commentary and criticism.   

The court also found that although the website solicited donations and advertised the services of another website, the overall nature of the website was non-commercial and benefited the public by promoting discussion of the issues presented in the articles on the website. However, the court found that the nontransformative character of the copying outweighed the consideration of its minimally commercial nature.  

Finally, and most importantly, the court found that posting entire news articles on the website had an adverse market effect on the copyright owners.  

See L.A. Times v. Free Republic, 2000 U.S. Dist. LEXIS 5669 (C.D. Cal. 2000). }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{I found something interesting on someone else's blog. May I quote it?},
 answer:   %{Probably. Short quotations will usually be fair use, not copyright infringement. The Copyright Act says that "fair use...for purposes such as criticism, comment, news reporting, teaching (including multiple copies for classroom use), scholarship, or research, is not an infringement of copyright." So if you are commenting on or criticizing an item someone else has posted, a court would likely find that you have a fair use right to quote. The law favors "transformative" uses }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Do I need to register my copyright?},
 answer:   %{You get copyright automatically when you create a work and "fix" or record it.  <a href="http://www.copyright.gov/register/">Registration with the Copyright Office</a> is not a prerequisite, but it can give you additional protection: you can only get statutory damages for infringement of a registered copyright.  A U.S. author must also register before filing a copyright lawsuit. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Am I free to copy the content from someone else's website verbatim?},
 answer:   %{No. While you are free to report the facts and ideas embodied in another person's article or web page, you shouldn't copy the entire page unless you can assert a fair use defense. Copyright does not protect facts or ideas, but it can protect the particular way someone has expressed them.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an operator of a visual search engine use the copyrighted images of another owner as "thumbnails" in its search engine?},
 answer:   %{Probably.  The creation and use of "thumbnails" -- smaller, lower resolution copies of an image the enlargement of which would lead to a loss of clarity of the image-- as part of such a search engine may be a fair use.  

The Ninth Circuit Court of Appeals recently held in Kelly v. Arriba Soft that displaying the copyrighted images of another as thumbnails on a search engine was a fair use because the thumbnails served a completely different purpose than the original images. Working through the four factor fair use analysis, the court emphasized that it was essential to determine if defendant's use was transformative in nature. It is more likely that a court will find fair use if the defendant's use of the image advances a purpose different than the copyright holder's, rather than merely superseding the object of the originals. For example, the Ninth Circuit found there to be a fair use since the displayed images were not for illustrative artistic purposes, but were rather used as part of an image search engine as a means to access other images and web sites. Even if defendant's website is operated for a commercial purpose, it may still be a fair use if the use of the image was "more incidental and less exploitative." The court in Kelly found that defendant's search engine did not directly profit from the use of plaintiff's images, and therefore that their use was not highly exploitative. In Kelly, the court also found that the use of the images would not hurt the plaintiff's market for the images.  

Kelly v. Arriba Soft Corporation, 336 F.3d 811(9th Cir. Cal. 2003). 

However, if there is an actual market for thumbnails, this may be copyright infringement.  The Central District of California recently granted an injunction preventing Google from displaying thumbnail size versions of Perfect 10}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the fair use doctrine permit an operator of a visual search engine -- or other Internet web site -- to "import" or provide an inline link to a copyrighted, full size image, where such importing/linking does not involve making a copy of the image? },
 answer:   %{As of now, there is no official decision with regard to this issue. The Ninth Circuit Court of Appeals withdrew its previous decision in which it held that a search engine may not display the full size images in this way without the copyright owner's permission because such a use infringed on the owner's exclusive right to publicly display his or her works. In its recently issued opinion (July 2003), the court determined that this issue did not need to be addressed, and the issue was remanded back to the lower court. }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is inline linking and framing? },
 answer:   %{Inline linking allows a website to import an image from another website and then include it on the website. The user is able to click on an image and then open a new window to display the full size image, within the original website.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can an internet service allow users to store and listen to compact discs sold by record companies through an internet connection?},
 answer:   %{Probably not. According to the court in UMG Recordings v. MP3.com, an internet company may not store MP3 music files to facilitate their retransmission. Reproducing audio compact discs in MP3 format does not transform the copyrighted work. An internet operator must do more than merely retransmit the original work in a different medium. The court in UMG also found that storing digital files in this way would have an adverse market effect on the record companies.  

UMG Recordings, Inc. v. MP3.com, Inc., 92 F. Supp. 2d 349, 350 (S.D.N.Y. 2000). }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the fair use doctrine permit individuals to upload and download digital audio files containing copyrighted music through a file-sharing service that facilitates transmission and retention of the files by its users?},
 answer:   %{No.  The courts that have considered this issue to date have held that this type of "peer to peer file sharing" violates the copyright owner's exclusive right to reproduce their copyrighted material and does not constitute a fair use.  

The Ninth Circuit Court of Appeals applied the four factor fair use analysis to address this issue. First, the court found that the purpose and character of such a use was not transformative, since the work was merely retransmitted in a different medium. Also, such use was found to be commercial in nature and resulted in the exploitation of copyrighted works since it saved the users the expense of purchasing the authorized copies. The court also focused on the fourth factor, the effect of the use on the market. The court concluded that the internet service harmed the market for the plaintiff's copyrighted material by reducing CD sales and by interfering with the copyright holder's attempts to charge for the same internet downloads.  

A&M Records v. Napster, 239 F.3d 1004 (9th Cir. Cal. 2001); see also MGM v. Grokster, 125 S. Ct. 2764 (2005).}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the fair use doctrine permit users to download MP3 files to make temporary copies of copyrighted sound recordings to "sample" the music before deciding whether to purchase the recording?},
 answer:   %{No.  The courts that have considered this issue thus far have held that allowing users to download a full, free, and permanent copy of the copyrighted recording would be a commercial use that would adversely affect the copyright owners' market for their work. The Napster court observed that "even if sampling enhanced the audio CD sales of the recording, the benefit to the copyright owner is not a sufficient indication of fair use." Further, the court held, even if the sampling benefited the copyright owner's audio CD sales, the copyright owner still enjoyed the right to develop alternative markets, such as the digital download market, and not to have such market usurped from them.  

A&M Records, Inc. v. Napster, Inc., 239 F.3d 1004 (9th Cir. 2001). }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a person or company create and streamline clips of movies over the internet to video retailers to play for their customers? },
 answer:   %{Probably not. It is not a fair use to stream such clips over the internet if the purpose is to promote the sale and rental of the videos. Such a use infringes on the copyright owner's exclusive rights to reproduce, publicly display and distribute their work, and to create derivative works.  

A court will apply the four factor fair use analysis to the individual facts of such a case to determine whether the use was fair. Courts have found that stream lining movie trailers for the purpose of promoting sales or rentals serves a commercial purpose and is not transformative since the use is not different than the purpose for which it was originally created. However, if the video trailer adds criticism or commentary to the original work, it is more likely that the court will consider it to be a fair use. Courts have also found that even if the movie clip is short and therefore only uses a small portion of the original work, the aggregation of scenes may reflect the themes and tone of the film in a way that interferes with the plaintiff's ability to evoke the same expressive values in its own previews. With regard to the effect of the use on the market, a misleading arrangement of scenes or a low quality clip could lead to an adverse effect on the copyright owner's market. Also, such previews could detract from sales on the copyright owner's official website.  

Video Pipeline, Inc. v. Buena Vista Home Entertainment, 192 F.Supp.2d 321(D.N.J. 2002).}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Is it fair use to electronically modify a movie to omit objectionable content?},
 answer:   %{No.  In Clean Flicks of Colorado, LLC v. Soderbergh, a U.S. District court held that editing movies by deleting }
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the look and feel of a website?},
 answer:   %{The look and feel of a website comprises its design aspects.  The "look" includes layout, colors, typefaces, etc.  The "feel" includes the behavior of dynamic elements such as buttons, boxes, and menus.}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{Is the look and feel of a website protected by copyright law?},
 answer:   %{An individual may own copyrights to the code and graphical design of a website.  In order for a website user interface to be considered copyrightable subject matter, it must be both fixed in a "tangible medium of expression" and original.  The code creating the look and feel of a website is fixed on a file in the hard drive, so it is likely considered a "tangible medium of expression."  To find a work is original, there must be some independent creation by the author, and some minimal degree of creativity.  Just because an individual puts time and effort into a work does not necessarily make the work original.  Although the level of creativity required is low, it may be difficult to find the originality required for copyright protection in simplistic websites that just arrange facts or information.  If, however, the visual user interface component contains some graphics or a creative, visual presentation, it will likely be considered original.    

Once it is determined that a website is copyrightable subject matter, a court will determine whether there is a substantial similarity between the protectable expressions compared.  To determine which elements are protectable and which are not, courts generally look at the level of structural abstraction.  Aspects of the website that are considered merely functional or ideas are not protected, and must therefore be separated prior to comparison.  Once the elements are separated, proving substantial similarity is not tremendously difficult.  It can be proven with circumstantial evidence that the wrongdoer had access to the work to copy it, or with direct evidence of copying.

See Computer Associates v. Altai, 775 F. Supp. 544 (E.D.N.Y. 1991).  

}
)

mapping[%{Copyright and Fair Use}] << q.id

q = RelevantQuestion.create!(
 question: %{What constitutes unlicensed copy and display of copyrighted material?},
 answer:   %{Unlicensed use or distribution of copyrighted works is illegal and may be considered a criminal act. Copyright law grants the exclusive right to use, copy, distribute, display and perform a copyrighted work to the owner of the copyright. The owner of the copyright is the only entity that may grant permission for anyone to use, copy, distribute, display and perform the work. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Does filing a counter-notification indicate that you are willing to defend yourself against a claim of copyright infringement?},
 answer:   %{Filing a counter-notification indicates that the subscriber has a "good faith belief that the material was removed or disabled as a result of mistake or misidentification of the material to be removed or disabled." [15 U.S.C. s 512(g)(c)(3)]  A counter-notification also requires a statement that the subscriber consents to the jurisdiction in which the address of the subscriber is located. [17 U.S.C. s 512(g)(3)(D)] 

Thus, the filing of a counter-notification does not explicitly indicate consent to defend against a claim of copyright infringement; it merely indicates a good faith belief that the challenged material is non-infringing.  An individual who believes that a user has infringed or is infringing upon his or her copyright may sue the user for infringement regardless of whether a take-down notice is sent to the service provider.  The safe-harbor rules provided under 17 U.S.C. Sec. 512 do not affect the right of a lawful copyright holder to sue a <i>user</i> who directly infringes his or her copyright. }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is an exclusive right in intellectual property? },
 answer:   %{Most governments recognize a bundle of exclusive rights in relation to works of authorship, inventions, and identifications of origin. These rights are sometimes spoken of under the umbrella term "intellectual property". An example is copyright, which grants a copyright holder a negative right to exclude others from exploiting his or her artistic or creative work. The position is generally similar with patents and trademarks. Exclusive rights arise from a grant of patent or registration of a trademark, while in other cases such rights may arise through use (eg. copyright or common-law trademark).

Holding an intellectual property right generally means that the rights holder can maintain certain controls in relation to the subject matter in which the IP right subsists. For example, a person who buys a copy of a computer program which is subject to copyright may use the software for personal use, but will probably be prohibited from creating or distributing copies of that software, subject to certain exceptions such as fair use or fair dealing, which vary widely from jurisdiction to jurisdiction.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Is there a DMCA notice-and-takedown requirement for trademark?},
 answer:   %{No. The <!--GET FAQLink 14 --> and notice-and-takedown requirements apply only to claims of <a href="<!--GET URL Question 9-->">copyright</a> infringement.  However, because <a href="<!--GET URL Question 709-->">CDA 230's immunity</a> does not apply to trademark either, Internet hosts may be concerned about possible <a href="<!--GET URL Question 398-->">contributory liability</a> if they do not remove alleged trademark infringement once notified of it.}
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{Does the DMCA require service providers to filter or monitor user postings to their sites?},
 answer:   %{No, the DMCA safe harbors apply to protect a service provider who responds expeditiously to notices of claimed infringement.  Nothing in the statute imposes affirmative obligations to watch for or block potential future infringements.  }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is cyberstalking?},
 answer:   %{It has been defined as the use of information and communications technology, particularly the Internet, by an individual or group of individuals, to harass another individual, group of individuals, or organization. The behavior includes false accusations, monitoring, the transmission of threats, identity theft, damage to data or equipment, the solicitation of minors for sexual purposes, and gathering information for harassment purposes. The harassment must be such that a reasonable person, in possession of the same information, would regard it as sufficient to cause another reasonable person distress.

The current U.S. anti-cyberstalking law can be found in 47 USCS ? 223

? 223.  Obscene or harassing telephone calls in the District of Columbia or in interstate or foreign communications 

(a) Prohibited acts generally. Whoever--
   (1) in interstate or foreign communications--
      (A) by means of a telecommunications device knowingly--
         (i) makes, creates, or solicits, and
         (ii) initiates the transmission of,
      any comment, request, suggestion, proposal, image, or other communication which is obscene or child pornography, with intent to annoy, abuse, threaten, or harass another person;
      (B) by means of a telecommunications device knowingly--
         (i) makes, creates, or solicits, and
         (ii) initiates the transmission of,
      any comment, request, suggestion, proposal, image, or other communication which is obscene or child pornography, knowing that the recipient of the communication is under 18 years of age, regardless of whether the maker of such communication placed the call or initiated the communication;
      (C) makes a telephone call or utilizes a telecommunications device, whether or not conversation or communication ensues, without disclosing his identity and with intent to annoy, abuse, threaten, or harass any person at the called number or who receives the communications;
      (D) makes or causes the telephone of another repeatedly or continuously to ring, with intent to harass any person at the called number; or
      (E) makes repeated telephone calls or repeatedly initiates communication with a telecommunications device, during which conversation or communication ensues, solely to harass any person at the called number or who receives the communication; or
   (2) knowingly permits any telecommunications facility under his control to be used for any activity prohibited by paragraph (1) with the intent that it be used for such activity,
 
shall be fined under title 18, United States Code, or imprisoned not more than two years, or both.
 
(b) Prohibited acts for commercial purposes; defense to prosecution.
   (1) Whoever knowingly--
      (A) within the United States, by means of telephone, makes (directly or by recording device) any obscene communication for commercial purposes to any person, regardless of whether the maker of such communication placed the call; or
      (B) permits any telephone facility under such person's control to be used for an activity prohibited by subparagraph (A), shall be fined in accordance with title 18, United States Code, or imprisoned not more than two years, or both.
   (2) Whoever knowingly--
      (A) within the United States, by means of telephone, makes (directly or by recording device) any indecent communication for commercial purposes which is available to any person under 18 years of age or to any other person without that person's consent, regardless of whether the maker of such communication placed the call; or
      (B) permits any telephone facility under such person's control to be used for an activity prohibited by subparagraph (A), shall be fined not more than $ 50,000 or imprisoned not more than six months, or both.
   (3) It is a defense to prosecution under paragraph (2) of this subsection that the defendant restricted access to the prohibited communication to persons 18 years of age or older in accordance with subsection (c) of this section and with such procedures as the Commission may prescribe by regulation.
   (4) In addition to the penalties under paragraph (1), whoever, within the United States, intentionally violates paragraph (1) or (2) shall be subject to a fine of not more than $ 50,000 for each violation. For purposes of this paragraph, each day of violation shall constitute a separate violation.
   (5) (A) In addition to the penalties under paragraphs (1), (2), and (5), whoever, within the United States, violates paragraph (1) or (2) shall be subject to a civil fine of not more than $ 50,000 for each violation. For purposes of this paragraph, each day of violation shall constitute a separate violation.
      (B) A fine under this paragraph may be assessed either--
         (i) by a court, pursuant to civil action by the Commission or any attorney employed by the Commission who is designated by the Commission for such purposes, or
         (ii) by the Commission after appropriate administrative proceedings.
   (6) The Attorney General may bring a suit in the appropriate district court of the United States to enjoin any act or practice which violates paragraph (1) or (2). An injunction may be granted in accordance with the Federal Rules of Civil Procedure.
 
(c) Restriction on access to subscribers by common carriers; judicial remedies respecting restrictions.
   (1) A common carrier within the District of Columbia or within any State, or in interstate or foreign commerce, shall not, to the extent technically feasible, provide access to a communication specified in subsection (b) from the telephone of any subscriber who has not previously requested in writing the carrier to provide access to such communication if the carrier collects from subscribers an identifiable charge for such communication that the carrier remits, in whole or in part, to the provider of such communication.
   (2) Except as provided in paragraph (3), no cause of action may be brought in any court or administrative agency against any common carrier, or any of its affiliates, including their officers, directors, employees, agents, or authorized representatives on account of--
      (A) any action which the carrier demonstrates was taken in good faith to restrict access pursuant to paragraph (1) of this subsection; or
      (B) any access permitted--
         (i) in good faith reliance upon the lack of any representation by a provider of communications that communications provided by that provider are communications specified in subsection (b), or
         (ii) because a specific representation by the provider did not allow the carrier, acting in good faith, a sufficient period to restrict access to communications described in subsection (b).
   (3) Notwithstanding paragraph (2) of this subsection, a provider of communications services to which subscribers are denied access pursuant to paragraph (1) of this subsection may bring an action for a declaratory judgment or similar action in a court. Any such action shall be limited to the question of whether the communications which the provider seeks to provide fall within the category of communications to which the carrier will provide access only to subscribers who have previously requested such access.
 
(d) Sending or displaying offensive material to persons under 18. Whoever--
   (1) in interstate or foreign communications knowingly--
      (A) uses an interactive computer service to send to a specific person or persons under 18 years of age, or
      (B) uses any interactive computer service to display in a manner available to a person under 18 years of age,
   any comment, request, suggestion, proposal, image, or other communication that is obscene or child pornography, regardless of whether the user of such service placed the call or initiated the communication; or
   (2) knowingly permits any telecommunications facility under such person's control to be used for an activity prohibited by paragraph (1) with the intent that it be used for such activity,
 
shall be fined under title 18, United States Code, or imprisoned not more than two years, or both.
 
(e) Defenses. In addition to any other defenses available by law:
   (1) No person shall be held to have violated subsection (a) or (d) solely for providing access or connection to or from a facility, system, or network not under that person's control, including transmission, downloading, intermediate storage, access software, or other related capabilities that are incidental to providing such access or connection that does not include the creation of the content of the communication.
   (2) The defenses provided by paragraph (1) of this subsection shall not be applicable to a person who is a conspirator with an entity actively involved in the creation or knowing distribution of communications that violate this section, or who knowingly advertises the availability of such communications.
   (3) The defenses provided in paragraph (1) of this subsection shall not be applicable to a person who provides access or connection to a facility, system, or network engaged in the violation of this section that is owned or controlled by such person.
   (4) No employer shall be held liable under this section for the actions of an employee or agent unless the employee's or agent's conduct is within the scope of his or her employment or agency and the employer (A) having knowledge of such conduct, authorizes or ratifies such conduct, or (B) recklessly disregards such conduct.
   (5) It is a defense to a prosecution under subsection (a)(1)(B) or (d), or under subsection (a)(2) with respect to the use of a facility for an activity under subsection (a)(1)(B) that a person--
      (A) has taken, in good faith, reasonable, effective, and appropriate actions under the circumstances to restrict or prevent access by minors to a communication specified in such subsections, which may involve any appropriate measures to restrict minors from such communications, including any method which is feasible under available technology; or
      (B) has restricted access to such communication by requiring use of a verified credit card, debit account, adult access code, or adult personal identification number.
   (6) The Commission may describe measures which are reasonable, effective, and appropriate to restrict access to prohibited communications under subsection (d). Nothing in this section authorizes the Commission to enforce, or is intended to provide the Commission with the authority to approve, sanction, or permit, the use of such measures. The Commission shall have no enforcement authority over the failure to utilize such measures. The Commission shall not endorse specific products relating to such measures. The use of such measures shall be admitted as evidence of good faith efforts for purposes of paragraph (5) in any action arising under subsection (d). Nothing in this section shall be construed to treat interactive computer services as common carriers or telecommunications carriers.
 
(f) Violations of law required; commercial entities, nonprofit libraries, or institutions of higher education.
   (1) No cause of action may be brought in any court or administrative agency against any person on account of any activity that is not in violation of any law punishable by criminal or civil penalty, and that the person has taken in good faith to implement a defense authorized under this section or otherwise to restrict or prevent the transmission of, or access to, a communication specified in this section.
   (2) No State or local government may impose any liability for commercial activities or actions by commercial entities, nonprofit libraries, or institutions of higher education in connection with an activity or action described in subsection (a)(2) or (d) that is inconsistent with the treatment of those activities or actions under this section: Provided, however, That nothing herein shall preclude any State or local government from enacting and enforcing complementary oversight, liability, and regulatory systems, procedures, and requirements, so long as such systems, procedures, and requirements govern only intrastate services and do not result in the imposition of inconsistent rights, duties or obligations on the provision of interstate services. Nothing in this subsection shall preclude any State or local government from governing conduct not covered by this section.
 
(g) Application and enforcement of other Federal law. Nothing in subsection (a), (d), (e), or (f) or in the defenses to prosecution under subsection (a) or (d) shall be construed to affect or limit the application or enforcement of any other Federal law.
 
(h) Definitions. For purposes of this section--
   (1) The use of the term "telecommunications device" in this section--
      (A) shall not impose new obligations on broadcasting station licensees and cable operators covered by obscenity and indecency provisions elsewhere in this Act [47 USCS ?? 151 et seq.];
      (B) does not include an interactive computer service; and
      (C) in the case of subparagraph (C) of subsection (a)(1), includes any device or software that can be used to originate telecommunications or other types of communications that are transmitted, in whole or in part, by the Internet (as such term is defined in section 1104 of the Internet Tax Freedom Act (47 U.S.C. 151 note)).
   (2) The term "interactive computer service" has the meaning provided in section 230(f)(2) [47 USCS ? 230(f)(2)].
   (3) The term "access software" means software (including client or server software) or enabling tools that do not create or provide the content of the communication but that allow a user to do any one or more of the following:
      (A) filter, screen, allow, or disallow content;
      (B) pick, choose, analyze, or digest content; or
      (C) transmit, receive, display, forward, cache, search, subset, organize, reorganize, or translate content.
   (4) The term "institution of higher education" has the meaning provided in section 101 of the Higher Education Act of 1965 [20 USCS ? 1001].
   (5) The term "library" means a library eligible for participation in State-based plans for funds under title III of the Library Services and Construction Act (20 U.S.C. 355e et seq.).
}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is misappropriation of copyrighted material?},
 answer:   %{One has misappropriated copyrighted material if he or she has acquired, disclosed, or used the material without the permission/license from the holder of the copyrighted material, where such activities were done through improper means or in breach of an obligation of confidentiality or non-use.  }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Must the receiver of a take-down notice notify the sender of the action it takes regarding the notice?},
 answer:   %{No.  Nothing in the DMCA requires the reciever of a take-down notice to notify the sender of the action it takes regarding the notice.  The DMCA only requires a service provider to notify the <i>subscriber</i> that the material has been removed or access to the material has been disabled, in cases where the allegedly infringing material is residing on the network controlled or operated by service provider at the discretion of the subscriber. [17 U.S.C. 512(g)(2)(A)]}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "willful infringement"?},
 answer:   %{Willful infringement occurs when the infringer knows that the material they are copying is protected by copyright. 

In many cases, the penalties for copyright infringement are greater if the infringement is willful.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Does copyright protect facts?},
 answer:   %{No.  Copyright protects only original expression, not discovered facts.  Creative selection and arrangement of facts is protected, but you can take the basic facts and rearrange them without infringing copyright.  Thus the publishers of a telephone book cannot sue an online phone book publisher for copyright infringement, even if it took the first publishers considerable effort to collect the listings.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What rights do I have if someone knowingly demands removal of material to which they do not have the rights?},
 answer:   %{Under Section 512(f) of the Copyright Act one who knowingly materially misrepresents a claim of infringement is liable for any damages, including costs and attorneys' fees, incurred by the alleged infringer or ISP injured by the misrepresentation, as the result of the service provider relying upon the misrepresentation in removing or disabling access to the material or activity claimed to be infringing.

If you are harmed by a mistaken takedown (as poster or as ISP), you may be able to recover damages and your legal fees from the person who made the wrongful claim.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean to have material "hosted" on a website?},
 answer:   %{Hosting (also known as Web site hosting, Web hosting, and Webhosting) is the business of housing, serving, and maintaining files for one or more Web sites. More important than the computer space that is provided for Web site files is the fast connection to the Internet.  Hosting allows the files to be stored in a location which is quicker for third parties to access. Typically, an individual business hosting its own site would require a similar connection and it would be expensive. Using a hosting service lets many companies share the cost of a fast Internet connection for serving files.

A number of Internet access providers, such as America Online, offer subscribers free space for a small Web site that is hosted by one of their computers. Geocities is a Web site that offers registered visitors similar free space for a Web site. While these services are free, they are also very basic.

A number of hosting companies describe their services as virtual hosting. Virtual hosting usually implies that their services will be transparent and that each Web site will have its own domain name and set of e-mail addresses. In most usages, hosting and virtual hosting are synonyms. Some hosting companies let you have your own virtual server, the appearance that you are controlling a server that is dedicated entirely to your site.
}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a repeat infringer?},
 answer:   %{Although Section 512(i) of the DMCA states that service providers seeking safe-harbor protection must have "adopted and reasonably implemented ... a policy that provides for the termination in appropriate circumstances of subscribers and account holders of the service provider?s system or network who are repeat infringers," it does not define "repeat infringers."  Treatise author David Nimmer  (Nimmer on Copyright) has suggested that one should not be labeled a "repeat infringer" until a court has found, on multiple occasions, that he has infringed.  Mere accusations, even repeated, should not turn a subscriber into a repeat infringer who must be terminated.  }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a hyperlinker be protected by the DMCA safe-harbor?},
 answer:   %{Someone who posts hyperlinks to online material may benefit from the DMCA safe harbor in section 512(d), "information location tools."  If you linked to materials without knowing they were infringing, but then receive a notice of claimed infringement, you can claim the statutory immunity if you remove the link expeditiously.  }
)

mapping[%{Linking}] << q.id

q = RelevantQuestion.create!(
 question: %{Can a hyperlinker be protected by the DMCA safe-harbor?},
 answer:   %{Someone who posts hyperlinks to online material may benefit from the DMCA safe harbor in section 512(d), "information location tools."  If you linked to materials without knowing they were infringing, but then receive a notice of claimed infringement, you can claim the statutory immunity if you remove the link expeditiously.  }
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Michigan anti-cyberstalking statute?},
 answer:   %{750.411h Stalking; definitions; violation as misdemeanor; penalties; probation; conditions; evidence of continued conduct as rebuttable presumption; additional penalties.

Sec. 411h.

(1) As used in this section:

(a) }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is criminal copyright infringement?},
 answer:   %{As defined by 15 USC section 506, criminal copyright infringement occurs if a person willfully infringes upon a copyright and it was done under any of the following circumstances: 1) for commercial advantage or private financial gain; 2) where the copies have a retail value of at least $1,000 and were made within a 180-day period; or 3) by distributing copyrighted work where the infringer knew or should have known the work was intended for public distribution. If found guilty, the infringer can be imprisoned for up to 10 years, depending on the type of infringement }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is criminal copyright infringement?},
 answer:   %{As defined by 15 USC section 506, criminal copyright infringement occurs if a person willfully infringes upon a copyright and it was done under any of the following circumstances: 1) for commercial advantage or private financial gain; 2) where the copies have a retail value of at least $1,000 and were made within a 180-day period; or 3) by distributing copyrighted work where the infringer knew or should have known the work was intended for public distribution. If found guilty, the infringer can be imprisoned for up to 10 years, depending on the type of infringement }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is a derivative work?},
 answer:   %{A derivative work is defined as "a work based upon one or more preexisting works" that is subject to copyright protection. See 17 U.S.C. 101. Such works may be in the form of a translation, musical arrangement, dramatization, fictionalization, motion picture version, sound recording, art or digital reproduction, or any other form in which a work is recast, transformed, or adapted from the original.}
)

mapping[%{Reverse Engineering}] << q.id

q = RelevantQuestion.create!(
 question: %{Does a posting on Chilling Effects mean that a takedown was unlawful or wrong? },
 answer:   %{No. Chilling Effects serves as a clearinghouse for cease and desist letters. Our goal is to educate the public about the different kinds of cease and desist letters--both legitimate and questionable--that are being sent to Internet publishers. We annotate the letters to help the public understand their legal language, and collect as many letters as possible to help the public understand the types of letters that are being sent and what searches are affected by them. By posting cease and desist notices, we are not authenticating them or making any judgment on the validity of the claims they raise.}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{Where do I send a DMCA counter-notification?},
 answer:   %{If you believe your material was wrongly removed in response to a DMCA notification, and you choose to counter-notify to demand replacement, you should send your counter-notification to the DMCA Agent of the site that removed your page.  If the agent isn't listed on the site, you can find a list of DMCA registered agents at <a href="http://www.copyright.gov/onlinesp/list/a_agents.html">the Copyright Office website</a>.}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is copyright notice?},
 answer:   %{A Copyright notice is placed on copies of a work buy the owner in order to inform the public that he holds copyright in the work. The public is then "on notice" that the work is copyrighted and unauthorized copying may infringe the copyright owner's rights.

Generally, a proper copyright notice must contain:
1. The symbol ©, the word “Copyright”, or the abbreviation “Copr.”
2. The year of first publication of the work.
3. The name of the copyright owner, an recognizable abbreviation of the copyright owner's name, or a generally known alternative designation of the owner.

The notice must also be placed on copies of a work so that they give reasonable notice of the claim of copyright.

The legal effect of proper copyright notice is to prevent a defendant in a copyright infringement suit to raise a defense based on innocent infringement. Simply, it prevents a defendant from saying "I had no idea that this work was copyrighted and I should not have to pay damages for willful infringement."

The specific notice provisions are set forth in <a href="http://www4.law.cornell.edu/uscode/17/401.html">17 U.S.C. § 401-406.
}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is jurisdiction?},
 answer:   %{Jurisdiction refers generally to the authorities who have legal power over you, or, where you could be sued.   As a general matter, you can only be subject to the laws of the place where you are present or doing business.  Mere publishing of a website, although it may be readable everywhere, does not make you subject to every state and country's law, but if your site offers business transactions with residents of a given state, you may be held to have "purposely availed" yourself of its laws and thus consented to its jurisdiction.}
)

mapping[%{International}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the duty of confidentiality of an employee?},
 answer:   %{Confidential information or trade secrets received during the course of an employer-employee relationship cannot be used or disclosed to the detriment of the employer during or after termination of the relationship, even if the employee and the employer had no express contract prohibiting the use or disclosure. 

However, an employee can use all the skills and knowledge he acquired during his employment, if the skills and knowledge are commonly used in the trade.

Many states have adopted the Uniform Trade Secrets Act, which is intended to provide states with a legal framework for improved trade-secret protection. The Act contains a definition of trade secrets which is consistent with common-law definitions. Factors used to determine if information is a trade secret include:

-The extent to which the information is known outside of the employer's business.

-The extent to which the information is known by employees and others involved in the business. 

-The extent of measures taken by the employer to guard the secrecy of the information. 

-The value of the information to the employer and to competitors. 

-The amount of effort or money expended by the company in developing the information. 

-The extent to which the information could be easily or readily obtained through an independent source.

Trade secrets need not be technical in nature. Market-related information such as information on current and future projects, as well as potential future opportunities for a firm, may constitute a trade secret.}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "willful copyright infringement"?},
 answer:   %{Willful infringement occurs when the infringer knows that the material they are copying is protected by copyright.

In many cases, the penalties for copyright infringement are greater if the infringement is willful.}
)

mapping[%{Derivative Works}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the duty of confidentiality of an employee?},
 answer:   %{Confidential information or trade secrets received during the course of an employer-employee relationship cannot be used or disclosed to the detriment of the employer during or after termination of the relationship, even if the employee and the employer had no express contract prohibiting the use or disclosure. 
However, an employee can use all the skills and knowledge he acquired during his employment, if the skills and knowledge are commonly used in the trade.

Many states have adopted the Uniform Trade Secrets Act, which is intended to provide states with a legal framework for improved trade-secret protection. The Act contains a definition of trade secrets which is consistent with common-law definitions. Factors used to determine if information is a trade secret include:

? The extent to which the information is known outside of the employer's business.
? The extent to which the information is known by employees and others involved in the business. 
? The extent of measures taken by the employer to guard the secrecy of the information. 
? The value of the information to the employer and to competitors. 
? The amount of effort or money expended by the company in developing the information. 
? The extent to which the information could be easily or readily obtained through an independent source.

Trade secrets need not be technical in nature. Market-related information such as information on current and future projects, as well as potential future opportunities for a firm, may constitute a trade secret.}
)

mapping[%{Trade Secret}] << q.id

q = RelevantQuestion.create!(
 question: %{What is tortious interference with a business interest?},
 answer:   %{Tortious interference with contract or business expectancy occurs when a person intentionally damages the plaintiff's contractual or other business relationship with a third party. }
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What are considered public records?},
 answer:   %{Public records is information that has been filed or recorded by local, state, federal or other government agencies, such as corporate and property records. Public records are created by the federal and local government, (vital records, immigration records, real estate records, driving records, criminal records, etc.) or by the individual (magazine subscriptions, voter registration, etc.). Most essential public records are maintained by the government and many are accessible to the public either free-of-charge or for an administrative fee. Availability is determined by federal, state, and local regulations.

}
)

mapping[%{Defamation}] << q.id

q = RelevantQuestion.create!(
 question: %{What are monetary damages?},
 answer:   %{Monetary damages are a category of "Special damages." They are awards which compensate plaintiffs for monetary losses. These may be actual losses (real lost sales) or reasonably predictable losses.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "willful copyright infringement"?},
 answer:   %{Willful infringement occurs when the infringer knows that the material they are copying is protected by copyright. In many cases, the penalties for copyright infringement are greater if the infringement is willful.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What are the counter-notice and put-back procedures?},
 answer:   %{<p>In order to ensure that copyright owners do not wrongly insist on the removal of materials that actually do not infringe their copyrights, the safe harbor provisions require service providers to notify the subscribers if their materials have been removed and to provide them with an opportunity to send a written notice to the service provider stating that the material has been wrongly removed.  [512(g)] If a subscriber provides a proper "counter-notice" claiming that the material does not infringe copyrights, the service provider must then promptly notify the claiming party of the individual's objection.  [512(g)(2)] If the copyright owner does not bring a lawsuit in district court within 14 days, the service provider is then required to restore the material to its location on its network. [512(g)(2)(C)]</p>

<p>A proper counter-notice must contain the following information:
<ul class="main"><li>The subscriber's name, address, phone number and physical or electronic signature [512(g)(3)(A)]
<li>Identification of the material and its location before removal [512(g)(3)(B)]
<li>A statement under penalty of perjury that the material was removed by mistake or misidentification [512(g)(3)(C)]
<li>Subscriber consent to local federal court jurisdiction, or if overseas, to an appropriate judicial body. [512(g)(3)(D)]</ul></p>

<p>If it is determined that the copyright holder misrepresented its claim regarding the infringing material, the copyright holder then becomes liable to the OSP for any damages that resulted from the improper removal of the material. [512(f)]</p>}
)

mapping[%{DMCA Safe Harbor}] << q.id

q = RelevantQuestion.create!(
 question: %{What is the Streisand Effect?},
 answer:   %{The "Streisand Effect" refers to the likelihood of a cease-and-desist demand attracting more attention to the complained-of material than it had before the demand. 

The effect gets its name from a 2003 incident in which Barbra Streisand sued a California photographer for including aerial photographs of her Malibu house on his coastal survey website. Instead of removing the image, the photographer publicized the suit, drawing further attention to the photo. See <a href="http://www.forbes.com/2007/05/10/streisand-digg-web-tech-cx_ag_0511streisand.html">Andy Greenberg, The Streisand Effect, Forbes</a>. Adelman, who maintained <a href="http://californiacoastline.org/">californiacoastline.org</a>, obtained dismissal of the suit under California’s anti-SLAPP law, and won attorneys’ fees and costs. See <a href="http://www.californiacoastline.org/streisand/fees-ruling.pdf">Streisand v. Adelman, No. SC 077 257</a> (L.A. Sup. Ct. May 10, 2004).}
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{What are some of the trademark issues that frequently arise online?},
 answer:   %{Trademark issues can arise around use of marks (words or images) in web pages, in domain names, in advertisements or keywords. A few of the most frequently-referenced questions include:

<blockquote><!--GET display Question 51-->
<!--GET display Question 52-->
<!--GET display Question 53-->
<!--GET display Question 56-->
<!--GET display Question 252-->
<!--GET display Question 255-->
<!--GET display Question 262-->
<!--GET display Question 344-->
<!--GET display Question 872-->
</blockquote>


For more information on Trademark, see the FAQs on <!--GET FAQLink 6-->.  For more information on Trademarks and Domain Names, see <!--GET FAQLink 2-->. }
)

mapping[%{Trademark}] << q.id

q = RelevantQuestion.create!(
 question: %{What is in the public domain?},
 answer:   %{The public domain refers to materials that are not protected under copyright law. Prior to 1978, a work could fall into the public domain if it was not registered or if it did not have proper notice. After 1978, there was no registration or notice requirement and thus a work would not automatically fall into the public domain.

A work may also fall into the public domain if its copyright expires. Under the 1909 Copyright Act, a work received protection for a 28 year period (works between 1964-1977 receive automatic renewal), with an option to renew the work for an additional 28 years (because of the Copyright Extension Act, a work created before 1978 can have protection for 95 years after publication). For works created after 1978, the copyright holder lasts for the life of the author + 70 years (the copyright holder's heirs retain the intellectual property rights).

So, you should not assume a work is in the public domain. You should first check with the Copyright Office.}
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{What does it mean to have material "hosted" on a website?},
 answer:   %{Hosting (also known as Web site hosting, Web hosting, and Webhosting) is the business of housing, serving, and maintaining files for one or more Web sites. More important than the computer space that is provided for Web site files is the fast connection to the Internet. Hosting allows the files to be stored in a location which is quicker for third parties to access. Typically, an individual business hosting its own site would require a similar connection and it would be expensive. Using a hosting service lets many companies share the cost of a fast Internet connection for serving files.

A number of Internet access providers, such as America Online, offer subscribers free space for a small Web site that is hosted by one of their computers. Geocities is a Web site that offers registered visitors similar free space for a Web site. While these services are free, they are also very basic.

A number of hosting companies describe their services as virtual hosting. Virtual hosting usually implies that their services will be transparent and that each Web site will have its own domain name and set of e-mail addresses. In most usages, hosting and virtual hosting are synonyms. Some hosting companies let you have your own virtual server, the appearance that you are controlling a server that is dedicated entirely to your site.}
)

mapping[%{Protest, Parody and Criticism Sites}] << q.id

q = RelevantQuestion.create!(
 question: %{What is "trade dress"?},
 answer:   %{Trade dress refers to characteristics of the visual appearance of a product or its packaging that signify the source of the product to consumers. The “look and feel” of a product or its packaging. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{When shouldn't I contact Chilling Effects? },
 answer:   %{Chilling Effects is not and cannot be your lawyer. 

We cannot help you execute a request to remove online content.  Chilling Effects serves as a repository of requests made to others, along with analyses of the legal claims. We are not responsible for the removal of material. }
)

mapping[%{Chilling Effects}] << q.id

q = RelevantQuestion.create!(
 question: %{What is defamation? },
 answer:   %{Defamation occurs when communication is made about an individual or group which causes a negative effect to the reputation or character of the individual or group, or to a certain portion of the community. }
)

mapping[%{Copyright}] << q.id

q = RelevantQuestion.create!(
 question: %{Partial removal},
 answer:   %{The submitter reports that only some of the materials identified in this complaint have been removed or disabled. }
)

mapping[%{Chilling Effects}] << q.id

mapping.each do |topic_name,question_ids|
  if topic = Topic.find_by_name(topic_name)
    topic.relevant_questions = RelevantQuestion.where(id: question_ids)
    topic.save!
  end
end
