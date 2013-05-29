require 'spec_helper'

describe Submission do
  it 'allows a file to be uploaded' do
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

  it 'does not attempt to create entities when none are submitted' do
    Entity.any_instance.should_not_receive(:save)
    EntityNoticeRole.any_instance.should_not_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title").save
  end

  it 'creates entities when they are submitted' do
    Entity.any_instance.should_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title", entities: [{
      name: 'I am a person', kind: 'individual', role: 'principal'
    }]).save
  end

  it 'creates entity_notice_roles when they are submitted' do
    EntityNoticeRole.any_instance.should_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title", entities: [{
      name: 'I am a person', kind: 'individual', role: 'principal'
    }]).save
  end

  def with_tempfile(&block)
    Tempfile.open('tempfile', &block)
  end
end
