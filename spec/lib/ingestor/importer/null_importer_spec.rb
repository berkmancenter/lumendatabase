require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::NullImporter do
  context ".handles?" do
    it "returns true" do
      expect(described_class.handles?('asdfasdf')).to be
    end
  end
end

