require 'rails_helper'
require 'ingestor'
require 'rspec/collection_matchers'

describe Ingestor::Importer::UnknownImporter do
  include ImporterFileHelpers

  it "handles everything" do
    expect(described_class).to handle(nil)
    expect(described_class).to handle('')
    expect(described_class).to handle('foo')
  end

  it "parses no works" do
    expect(described_class.new('').works).to be_empty
  end

  it "provides file_uploads" do
    touch_file('tmp/original.txt')
    touch_file('tmp/supporting.txt')
    importer = described_class.new('tmp/original.txt', 'tmp/supporting.txt')

    expect(importer).to have(2).file_uploads
    expect(importer.file_uploads.map(&:file_file_name)).to match_array(
      %w( original.txt supporting.txt )
    )
  end

  context "#require_review_if_works_empty?" do
    it "should be false" do
      importer = described_class.new('')

      expect(importer.require_review_if_works_empty?).to be false
    end
  end

end
