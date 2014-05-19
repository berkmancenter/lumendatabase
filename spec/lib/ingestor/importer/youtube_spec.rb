require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Youtube do
  it "has a default recipient" do
    expect(described_class.new('').default_recipient).to eq 'Google, Inc.'
  end

end
