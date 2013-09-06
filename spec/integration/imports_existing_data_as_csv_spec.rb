require 'spec_helper'
require 'ingestor'

feature "Importing CSV" do
  scenario "notices are created" do
    ingestor = Ingestor::LegacyCsv.open(
      'spec/support/example_files/example_notice_export.csv'
    )
    ingestor.import

    notice = Dmca.last
    expect(notice.title).to eq ' DMCA (Copyright) Complaint to Google'
    expect(notice.works.length).to eq 2
    expect(notice.infringing_urls.map{|u| u.url}).to match_array(
      [
        "http://infringing.example.com/url_0",
        "http://infringing.example.com/url_1",
        "http://infringing.example.com/url_second_0",
        "http://infringing.example.com/url_second_1"
      ]
    )
  end
end
