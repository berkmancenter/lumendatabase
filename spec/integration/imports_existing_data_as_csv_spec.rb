require 'rails_helper'
require 'ingestor'

feature "Importing CSV" do
  before do
    create(:topic, name: 'Foobar')
    ingestor = Ingestor::Legacy.open_csv(
      'spec/support/example_files/example_notice_export.csv'
    )
    ingestor.logger.level = Logger::ERROR
    ingestor.import
    binding.pry
    (
      @primary_format_notice,
      @secondary_dmca_notice,
      @twitter_notice,
      @primary_notice_without_data
    ) = DMCA.order(:id)

    (
      @secondary_other_notice,
      @youtube_otherlegal_notice,
    ) = Other.order(:id)

    @youtube_defamation_notice = Defamation.last
    (
     @youtube_trademark_d_notice,
     @youtube_trademark_b_notice,
     @youtube_counterfeit_notice,
    ) = Trademark.order(:id)
  end


  after do
    FileUtils.rm_rf 'spec/support/example_files-failures/'
  end

  context "from the Youtube otherlegal format" do
    subject(:notice) { @youtube_otherlegal_notice }

    scenario "notices are created" do
      expect(notice.title).to eq 'Takedown Request via Other Legal Complaint to YouTube'
      expect(notice.works.length).to eq 1
      expect(notice.infringing_urls.map(&:url)).to match_array(
        %w|https://www.youtube.com/watch?v=xszr9lUlPE8
https://www.youtube.com/watch?v=w2-DjJ
https://www.youtube.com/watch?v=PlsCEe|
      )
      expect(notice).to have(1).original_document
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 10078
    end

    scenario "the correct entities are created" do
      expect(notice).to have(3).entity_notice_roles
      expect(notice.sender.name).to eq "PeterDancer"
      expect(notice.principal.name).to eq "Peter Dancer"
      expect(notice.recipient_name).to eq "YouTube (Google, Inc.)"
    end
  end

  context "from the Youtube counterfeit format" do
    subject(:notice) { @youtube_counterfeit_notice }

    scenario "notices are created" do
      expect(notice.title).to eq 'Takedown Request via Counterfeit Complaint to YouTube'
      expect(notice.works.length).to eq 1
      expect(notice.infringing_urls.map(&:url)).to match_array(
        %w|http://www.youtube.com/watch?v=H0r8U-|
      )
      expect(notice).to have(1).original_document
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 1007
      expect(notice.mark_registration_number).to eq '12200000'
    end

    scenario "the correct entities are created" do
      expect(notice).to have(3).entity_notice_roles
      expect(notice.sender_name).to eq "Adelaid Bourbou, Internet Unit, The Federation"
      expect(notice.principal_name).to eq "Humboldt SA, Genève"
      expect(notice.recipient_name).to eq "YouTube (Google, Inc.)"
    end
  end

  context "from the Youtube Trademark-b format" do
    subject(:notice) { @youtube_trademark_b_notice }

    scenario "notices are created" do
      expect(notice.title).to eq 'Takedown Request via Trademark Complaint to YouTube'
      expect(notice.works.length).to eq 1
      expect(notice.infringing_urls.map(&:url)).to match_array(
        %w|https://www.youtube.com/user/ThisChipmunks|
      )
      expect(notice).to have(1).original_document
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 1006
      expect(notice.mark_registration_number).to eq '29350000'
    end

    scenario "the correct entities are created" do
      expect(notice).to have(3).entity_notice_roles
      expect(notice.sender_name).to eq "Tracy Papagallo, outside counsel"
      expect(notice.principal_name).to eq "Bagdad Productions, LLC"
      expect(notice.recipient_name).to eq "YouTube (Google, Inc.)"
    end
  end

  context "from the Youtube Trademark-d format" do
    subject(:notice) { @youtube_trademark_d_notice }

    scenario "notices are created" do
      expect(notice.title).to eq 'Takedown Request via Trademark Complaint to YouTube'
      expect(notice.works.length).to eq 1
      expect(notice.infringing_urls.map(&:url)).to match_array(
        %w|http://www.youtube.com/watch?v=iPK
       http://www.youtube.com/watch?v=6HG
       http://www.youtube.com/watch?v=FzH|
      )
      expect(notice).to have(1).original_document
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 1005
      expect(notice.mark_registration_number).to eq '28950000'
    end

    scenario "the correct entities are created" do
      expect(notice).to have(3).entity_notice_roles
      expect(notice.sender_name).to eq "Jonathan Clucker Rebar, Attorney for Best Example Pest Defense, Inc."
      expect(notice.principal_name).to eq "BEST EXAMPLE PEST DEFENSE, INC."
      expect(notice.recipient_name).to eq "YouTube (Google, Inc.)"
    end
  end

  context "from the Youtube Defamation format" do
    subject(:notice) { @youtube_defamation_notice }

    scenario "notices are created" do
      expect(notice.title).to eq 'Takedown Request via Defamation Complaint to YouTube'
      expect(notice.works.length).to eq 1
      expect(notice.infringing_urls.map(&:url)).to match_array(
        %w|https://www.youtube.com/watch?v=7uC2cJz0 https://www.youtube.com/watch?v=lRu8rSY|
      )
      expect(notice).to have(1).original_document
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 2000
    end

    scenario "the correct entities are created" do
      expect(notice).to have(3).entity_notice_roles
      expect(notice.sender_name).to eq "Timothy H. Fellpee, Attorney for FlimmComm Wireless"
      expect(notice.principal_name).to eq "FlimmComm Wireless"
      expect(notice.recipient_name).to eq "Youtube (Google, Inc.)"
    end
  end

  context "from the primary google reporting format" do
    subject(:notice) { @primary_format_notice }

    scenario "notices are created" do
      expect(notice.title).to eq 'DMCA (Copyright) Complaint to Google'
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
      expect(notice.topics.pluck(:name)).to include('Foobar')
      expect(upload_contents(notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/original_notice_source.txt'
      )
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 1000
      expect(notice).to have(1).supporting_document
      expect(upload_contents(notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/original.jpg'
      )
    end

    scenario "the correct entities are created" do
      expect(notice).to have(4).entity_notice_roles
      expect(notice.sender_name).to eq "JG Wentworth Associates"
      expect(notice.attorney_name).to eq "John Wentworth"
      expect(notice.principal_name).to eq "Kundan Singh"
      expect(notice.recipient_name).to eq "Google, Inc. [Blogger]"
    end
  end

  context "from the secondary google reporting format" do
    subject(:notice) { @secondary_dmca_notice }

    scenario "a dmca notice is created" do
      expect(notice.title).to eq 'Secondary Google DMCA Import'
      expect(notice.works.length).to eq 1
      expect(notice.infringing_urls.map(&:url)).to match_array(
        %w|http://www.example.com/unstoppable.html
http://www.example.com/unstoppable_2.html
http://www.example.com/unstoppable_3.html|
      )
      expect(notice).to have(1).original_document
      expect(notice.topics.pluck(:name)).to include('Foobar')
      expect(upload_contents(notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_dmca_notice_source.html'
      )
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 1001
      expect(notice).to have(1).supporting_document
      expect(upload_contents(notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_dmca_notice_source-2.html'
      )
    end
  end

  context "from the secondary other format" do
    subject(:notice) { @secondary_other_notice }

    scenario "an other notice is created" do
      expect(notice.title).to eq 'Secondary Google Other Import'
      expect(notice.works.length).to eq 1
      expect(notice.infringing_urls.map(&:url)).to match_array(
        %w|http://www.example.com/asdfasdf
        http://www.example.com/infringing|
      )
      expect(notice).to have(1).original_document
      expect(notice.topics.pluck(:name)).to include('Foobar')
      expect(upload_contents(notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_other_notice_source.html'
      )
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to eq 1002
      expect(notice).to have(1).supporting_document
      expect(upload_contents(notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/secondary_other_notice_source-2.html'
      )
    end
  end

  context "from the twitter format" do
    subject(:notice) { @twitter_notice }

    scenario "a notice is created" do
      expect(notice.title).to eq 'Twitter Import'
      expect(notice.works.length).to eq 2
      expect(notice.infringing_urls.map(&:url)).to match_array([
        'https://twitter.com/NoMatter/status/12345',
        'https://twitter.com/NoMatter/status/4567',
      ])
      expect(notice).to have(1).original_document
      expect(notice.topics.pluck(:name)).to include('Foobar')
      expect(upload_contents(notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/original_twitter_notice_source.txt'
      )
      expect(notice.action_taken).to eq ''
      expect(notice.submission_id).to be_nil
      expect(notice).to have(1).supporting_document
      expect(upload_contents(notice.supporting_documents.first)).to eq File.read(
        'spec/support/example_files/original_twitter_notice_source.html'
      )
    end
  end

  context "from a google notice without data" do
    subject(:notice) { @primary_notice_without_data }

    scenario "a notice is created and entity info is recovered from the file" do
      expect(notice.title).to eq 'Untitled'
      expect(notice.works.length).to eq 2
      expect(notice).to have(1).original_document
      expect(notice.entities.map(&:name)).to match_array(
        ["Copyright Owner LLC", "Google, Inc.", "Joe Schmoe"]
      )
      expect(upload_contents(notice.original_documents.first)).to eq File.read(
        'spec/support/example_files/original_notice_source_2.txt'
      )
      expect(notice.action_taken).to eq ''
    end
  end

  private

  def upload_contents(file_upload)
    File.read(file_upload.file.path)
  end
end
