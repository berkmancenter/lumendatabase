require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::UnknownImporter do
  it "handles everything" do
    expect(described_class).to handle(nil)
    expect(described_class).to handle('')
    expect(described_class).to handle('foo')
  end

  it "parses no works" do
    expect(described_class.new('').works).to be_empty
  end

  it "provides file_uploads" do
    touch('tmp/original.txt')
    touch('tmp/supporting.txt')
    importer = described_class.new('tmp/original.txt', 'tmp/supporting.txt')

    expect(importer).to have(2).file_uploads
    expect(importer.file_uploads.map(&:file_file_name)).to match_array(
      %w( original.txt supporting.txt )
    )
  end

  private

  def touch(path)
    File.open(path, 'w') { }
  end
end
