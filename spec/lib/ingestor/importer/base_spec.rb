require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Base do
  context ".read_file" do
    it "does not garble characters when faced with mixed charsets" do
      content = described_class.read_file('spec/support/example_files/mixed-charset-source.html')
      expect(content).to be_valid_encoding
      expect(content).to include  '廣記商行」と検索する際の'
    end
  end
end
