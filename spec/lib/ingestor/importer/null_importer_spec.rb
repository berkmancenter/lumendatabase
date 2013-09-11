require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::NullImporter do
  it 'exposes the same public interface as Ingestor::Importer::Google' do
    expect(described_class).to match_interface_of(Ingestor::Importer::Google)
  end
end
