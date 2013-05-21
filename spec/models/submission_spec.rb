require 'spec_helper'

describe Submission do
  it 'allows a file to uploaded' do
    with_tempfile do |fh|
      fh.write 'Some content'
      fh.flush

      uploaded_file = Rack::Test::UploadedFile.new(fh.path, "text/pdf")

      Submission.new(title: 'A title', file: uploaded_file).save
    end

    expect(FileUpload.last.read).to eq 'Some content'
  end

  it 'does not attempt to create a FileUpload when parameters absent' do
    FileUpload.any_instance.should_not_receive(:save)
    Notice.any_instance.stub(:save).and_return(true)

    Submission.new(title: "A Title").save
  end

  def with_tempfile(&block)
    Tempfile.open('tempfile', &block)
  end
end
