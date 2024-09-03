require 'rails_helper'

describe 'rake lumen:import_github_notices', type: :task, vcr: true do
  before :all do
    create(:court_order, :with_document)
    ENV['GH_IMPORT_DATE_FROM'] = '2024-07-19T00:00:00Z'
  end

  it 'ingests github notices' do
    # See /spec/vcr/rake_lumen_import_github_notices for the cassette

    initial_count = Notice.count

    task.execute

    notices = Notice.last(3)
    expect(notices[0].principal.name).to eq('Marval Software Group')
    expect(notices[1].principal.name).to eq('Codility')
    expect(notices[2].principal.name).to eq('Ketchep')

    expect(notices[0].recipient.name).to eq('GitHub')
    expect(notices[1].recipient.name).to eq('GitHub')
    expect(notices[2].recipient.name).to eq('GitHub')

    expect(notices[0].works.first.infringing_urls.length).to eq(0)
    expect(notices[1].works.first.infringing_urls.length).to eq(1)
    expect(notices[2].works.first.infringing_urls.length).to eq(2)

    expect(notices[0].works.first.description).to eq("\n \n The software is posted in a [private] on GitHub by a user deliteser112. I can provide the threatening email sent to our company.\n \n ")
    expect(notices[1].works.first.description).to eq(" Before disabling any content in relation to this takedown notice, GitHub\n - contacted the owners of some or all of the affected repositories to give them an opportunity to [make changes](https://docs.github.com/en/github/site-policy/dmca-takedown-policy#a-how-does-this-actually-work).\n - provided information on how to [submit a DMCA Counter Notice](https://docs.github.com/en/articles/guide-to-submitting-a-dmca-counter-notice).\n \n To learn about when and why GitHub may process some notices this way, please visit our [README](https://github.com/github/dmca/blob/master/README.md#anatomy-of-a-takedown-notice).\n \n ---\n \n DMCA Notification  \n The following information is presented for the purposes of removing web content that infringes on our copyright per the Digital Millennium Copyright Act. We appreciate your enforcement of copyright law and support of our rights in this matter.\n \n Identification of Copyrighted Work  \n The copyrighted work at issue is the text that appears on codility.com and its related pages. The pages in question contain a clear copyright notification and are the intellectual property of the complainant.\n \n Identification of Infringed Material  \n The following copyrighted paragraphs have been allegedly copied from the copyrighted work:\n \n 1) Link: https://github.com/manasch/placements/blob/main/placements/egnyte.md  \n Text starting from: \"There is an array A of N integers and three\"  \n to: \"function should return 15. Only one tile can be used\"\n \n \n Notifying Party\n \n Codility Limited  \n Attn: [private]  \n [private]  \n [private]  \n [private]  \n [private]  \n [private]  \n [private]  \n \n [private]  \n Copyright Owners Statement\n \n I have a good faith belief that use of the copyrighted materials described above on the allegedly infringing web pages is not authorized by the copyright owner, its agent, or the law.  \n I have taken fair use into consideration. I swear, under penalty of perjury, that the information in the notification is accurate and that I am authorized to act on behalf of the copyright owner of an exclusive right that is allegedly infringed.")
    expect(notices[2].works.first.description).to eq("\n \n \"Deflection Pro\" is a paid iOS app that is distributed only through the Apple App Store by Ketchep.com, LLC as \"Blue Ketchep\".\n \n https://apps.apple.com/us/app/deflection-pro/id1217160203?platform=iphone\n \n Ketchep.com, LLC owns the app logo, all trademarks, marketing materials, and assets that are bundled with the app. The app's logo is a grayscale I beam with a downward arrow and dark background and it can be found within the IPA file as well as on the Apple App Store.\n \n The distribution of the app's logo in this repository does not constitute \"fair use\", since the logo is being used solely to support the unauthorized distribution of the pirated software. This repository is being used as a CDN for the ipauniverse.com. The app's logo (hosted on github) is being used in this page to help users find pirated copies of the app: https://www.ipauniverse.com/2024/04/deflection-pro-v900.html\n \n ")

    final_count = Notice.count
    expect(final_count - initial_count).to eq(3)
  end
end
