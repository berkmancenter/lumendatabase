require 'spec_helper'

describe FileUpload do
  it { should have_attached_file(:file) }
  it { should belong_to :notice }
  it { should have_db_index :notice_id }

  context 'automatic validations' do
    it { should ensure_length_of(:kind).is_at_most(255) }
  end

  context "file_type" do
    it "returns PDF for PDFs" do
      for_each_mime_type(['application/pdf']) do |file_upload|
        expect(file_upload.file_type).to eq 'PDF'
      end
    end

    it "returns Image for mime types that begin with image/" do
      mime_types = %w( image/jpeg image/png image/anything )

      for_each_mime_type(mime_types) do |file_upload|
        expect(file_upload.file_type).to eq 'Image'
      end
    end

    it "returns Document for anything else" do
      mime_types = %w( video/mp4 application/octet-stream not-image/flim-flam )

      for_each_mime_type(mime_types) do |file_upload|
        expect(file_upload.file_type).to eq 'Document'
      end
    end
  end

  private

  def for_each_mime_type(mime_types, &block)
    mime_types.each do |mime|
      file_upload = FileUpload.new(file_content_type: mime)

      yield file_upload
    end
  end
end
