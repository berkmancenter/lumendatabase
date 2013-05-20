require 'spec_helper'

describe Submission do
  it 'allows a file to uploaded' do
    with_tempfile do |fh|
      fh.write 'Some content'
      fh.flush

      uploaded_file = Rack::Test::UploadedFile.new(fh.path, "text/pdf")

      Submission.create!(title: 'A title', file: uploaded_file)
    end

    with_tempfile do |fh|
      file = FileUpload.last
      file.file.copy_to_local_file(:original, fh.path)

      expect(fh.read).to eq 'Some content'
    end
  end

  it 'does not attempt to create a FileUpload when parameters absent' do
    FileUpload.should_not_receive(:create!)
    Notice.stub(:create!)

    Submission.create!(title: "A Title")
  end

  def with_tempfile(&block)
    Tempfile.open('tempfile', &block)
  end
end
