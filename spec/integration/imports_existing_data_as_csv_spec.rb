require 'spec_helper'
require 'ingestor'

feature "Importing CSV" do
  before do
    ingestor = Ingestor::LegacyCsv.open(
      'spec/support/example_files/example_notice_export.csv'
    )
    ingestor.logger.level = Logger::ERROR
    ingestor.import
    (
      @primary_format_notice,
      @secondary_dmca_notice,
      @twitter_notice
    ) = Dmca.order(:id)

    @secondary_other_notice = Other.last
  end

  after do
    FileUtils.rm_rf 'spec/support/example_files-failures/'
  end

  context "from the primary google reporting format" do
    scenario "notices are created" do
      expect(@primary_format_notice.title).to eq ' DMCA (Copyright) Complaint to Google'
      expect(@primary_format_notice.works.length).to eq 2
      expect(@primary_format_notice.infringing_urls.map(&:url)).to match_array(
        [
          "http://infringing.example.com/url_0",
          "http://infringing.example.com/url_1",
          "http://infringing.example.com/url_second_0",
          "http://infringing.example.com/url_second_1"
        ]
      )
      expect(@primary_format_notice).to have(1).original_document
      expect(upload_contents(@primary_format_notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/original_notice_source.txt'
      )
      expect(@primary_format_notice).to have(1).supporting_document
      expect(upload_contents(@primary_format_notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/original.jpg'
      )
    end
  end

  context "from the secondary google reporting format" do
    scenario "a dmca notice is created" do
      expect(@secondary_dmca_notice.title).to eq 'Secondary Google DMCA Import'
      expect(@secondary_dmca_notice.works.length).to eq 1
      expect(@secondary_dmca_notice.infringing_urls.map(&:url)).to match_array(
        %w|http://www.example.com/unstoppable.html
http://www.example.com/unstoppable_2.html
http://www.example.com/unstoppable_3.html|
      )
      expect(@secondary_dmca_notice).to have(1).original_document
      expect(upload_contents(@secondary_dmca_notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_dmca_notice_source.html'
      )
      expect(@secondary_dmca_notice).to have(1).supporting_document
      expect(upload_contents(@secondary_dmca_notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_dmca_notice_source-2.html'
      )
    end

    scenario "an other notice is created" do
      expect(@secondary_other_notice.title).to eq 'Secondary Google Other Import'
      expect(@secondary_other_notice.works.length).to eq 1
      expect(@secondary_other_notice.infringing_urls.map(&:url)).to match_array(
        %w|http://www.example.com/asdfasdf
        http://www.example.com/infringing|
      )
      expect(@secondary_other_notice).to have(1).original_document
      expect(upload_contents(@secondary_other_notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_other_notice_source.html'
      )
      expect(@secondary_other_notice).to have(1).supporting_document
      expect(upload_contents(@secondary_other_notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_other_notice_source-2.html'
      )
    end

  end

  context "from the twitter format" do
    scenario "a notice is created" do
      expect(@twitter_notice.title).to eq 'Twitter Import'
      expect(@twitter_notice.works.length).to eq 2
      expect(@twitter_notice.infringing_urls.map(&:url)).to match_array([
        'https://twitter.com/NoMatter/status/12345',
        'https://twitter.com/NoMatter/status/4567',
      ])
      expect(@twitter_notice).to have(1).original_document
      expect(upload_contents(@twitter_notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/original_twitter_notice_source.txt'
      )
      expect(@twitter_notice).to have(1).supporting_document
      expect(upload_contents(@twitter_notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/original_twitter_notice_source.html'
      )
    end
  end

  private

  def upload_contents(file_upload)
    File.read(file_upload.file.path)
  end
end
