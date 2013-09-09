require 'spec_helper'
require 'ingestor'

feature "Importing CSV" do
  scenario "notices are created" do
    ingestor = Ingestor::LegacyCsv.open(
      'spec/support/example_files/example_notice_export.csv'
    )
    ingestor.logger.level = Logger::ERROR
    ingestor.import

    notice = Dmca.last
    expect(notice.title).to eq ' DMCA (Copyright) Complaint to Google'
    expect(notice.works.length).to eq 2
    expect(notice.infringing_urls.map(&:url)).to match_array(
      [
        "http://infringing.example.com/url_0",
        "http://infringing.example.com/url_1",
        "http://infringing.example.com/url_second_0",
        "http://infringing.example.com/url_second_1"
      ]
    )
    expect(notice).to have(1).original_document
    expect(upload_contents(notice.original_documents.first)).to eq File.read(
      'spec/support/example_files/original_notice_source.txt'
    )
    expect(notice).to have(1).supporting_document
    expect(upload_contents(notice.supporting_documents.first)).to eq File.read(
      'spec/support/example_files/original.jpg'
    )
  end

  private

  def upload_contents(file_upload)
    File.read(file_upload.file.path)
  end
end
