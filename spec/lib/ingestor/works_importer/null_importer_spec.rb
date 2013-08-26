require 'spec_helper'
require 'ingestor'

describe Ingestor::WorksImporter::NullImporter do
  context ".handles?" do
    it "returns true" do
      expect(described_class.handles?('asdfasdf')).to be
    end
  end

  context ".works" do
    it "returns an empty array" do
      expect(described_class.works('asdfasdf')).to eq []
    end
  end
end

