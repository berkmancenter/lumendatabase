require 'spec_helper'
require 'ingestor'

describe Ingestor::WorksImporter::Dispatcher do
  context "invalid source files" do
    ['', nil].each do |file_path|
      it "returns an empty array when file_path is #{file_path.class}" do
        expect(described_class.import(file_path)).to eq []
      end
    end

    it "returns an empty array when no registered importers want to handle a file" do
      expect(described_class.import('spec/support/example_files/original.jpg')).to eq []
    end
  end

  it "can deduce the original file" do
    Ingestor::WorksImporter::Google.should_receive(:handles?).with(
      'spec/support/example_files/original_notice_source.txt'
    ).and_return(true)

    importer = described_class.import(
      'spec/support/example_files/original_notice_source.txt,spec/support/example_files/supporting.jpg'
    )
  end

end
