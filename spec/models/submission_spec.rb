require 'spec_helper'

describe Submission do
  it "allows a file to be uploaded" do
    with_tempfile do |fh|
      fh.write 'Some content'
      fh.flush

      uploaded_file = Rack::Test::UploadedFile.new(fh.path, "text/pdf")

      Submission.new(title: 'A title', file: uploaded_file).save
    end

    expect(FileUpload.last.read).to eq 'Some content'
  end

  it "does not attempt to create a FileUpload when parameters absent" do
    FileUpload.any_instance.should_not_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title").save
  end

  it "assigns the notice's categories by ID" do
    categories = create_list(:category, 3)
    submission = Submission.new(
      title: "A Title",
      category_ids: categories.map(&:id)
    )

    submission.save

    notice = Notice.last
    expect(notice.categories).to match_array(categories)
    categories.each do |category|
      expect(category.reload.notices).to eq [notice]
    end
  end

  it "ignores invalid category IDs" do
    submission = Submission.new(
      title: "A Title",
      category_ids: [1,2,3]
    )

    submission.save

    expect(Notice.last.categories).to be_empty
  end

  it "does not attempt to create entities when none are submitted" do
    Entity.any_instance.should_not_receive(:save)
    EntityNoticeRole.any_instance.should_not_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title").save
  end

  it "creates entities when they are submitted" do
    Entity.any_instance.should_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title", entities: [{
      name: 'I am a person', kind: 'individual', role: 'principal'
    }]).save
  end

  it "creates entity_notice_roles when they are submitted" do
    EntityNoticeRole.any_instance.should_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title", entities: [{
      name: 'I am a person', kind: 'individual', role: 'principal'
    }]).save
  end

  it "assigns the Notice's source from params" do
    submission = Submission.new(title: "A title", source: "Arbitrary source")

    submission.save

    expect(Notice.last.source).to eq "Arbitrary source"
  end

  context "works" do
    it "creates works with metadata" do
      submission = Submission.new(
        title: "A title",
        works: [
          { url: 'http://www.example.com/original_work.pdf',
            description: 'Video and images produced by Foocorp',
            infringing_urls: [
              'http://www.example.com/infringing_url1',
              'http://www.example.com/infringing_url2',
              'http://www.example.com/infringing_url3',
              'http://www.example.com/infringing_url4'
            ]
          }
        ]
      )
      submission.save

      notice = Notice.last
      work = notice.works.first
      expect(notice.works.count).to eq 1
      expect(work.url).to eq 'http://www.example.com/original_work.pdf'
      expect(work.infringing_urls.map(&:url)).to eq [
          'http://www.example.com/infringing_url1',
          'http://www.example.com/infringing_url2',
          'http://www.example.com/infringing_url3',
          'http://www.example.com/infringing_url4'
      ]
    end
  end

  private

  def with_tempfile(&block)
    Tempfile.open('tempfile', &block)
  end
end
