require 'spec_helper'

describe FileUpload, type: :model do
  it { is_expected.to have_attached_file(:file) }
  it { is_expected.to belong_to :notice }
  it { is_expected.to have_db_index :notice_id }
  it { is_expected.to validate_inclusion_of(:kind).in_array %w( original supporting ) }

  context 'automatic validations' do
    it { is_expected.to validate_length_of(:kind).is_at_most(255) }
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

  context "attachments" do
    it "have default file names" do
      file_upload = build(:file_upload)
      expect(file_upload.file_file_name).to match 'factory_file'
    end

    it "can have file names overridden" do
      file_upload = create(:file_upload, file_name: 'foo.jpg')
      expect(file_upload.file_file_name).to eq 'foo.jpg'
    end

    it "have valid file name when file_name is blank" do
      file_upload = create(:file_upload, file_name: '')
      expect(file_upload.file_file_name).to match 'factory_file'
    end

    it "have unsavory characters stripped from file names" do
      [
       'bsdfsdf asdflkasdfjasdf /.pdf',
       'b../../.pdf',
       'c:\\documents\asdfasdf.fdf',
       'fcwSDFasdf & fldifs.jpg',
      ].each do |file_name|
        file_upload = create(:file_upload, file_name: file_name)
        expect(file_upload.file_file_name).to match /\A[a-z\d\.\-_ ]+\Z/i
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
