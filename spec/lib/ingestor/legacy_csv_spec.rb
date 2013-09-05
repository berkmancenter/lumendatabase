require 'spec_helper'
require 'ingestor'

describe Ingestor::LegacyCsv do
  include IngestorHelpers

  it "is enumerable" do
    ingestor = described_class.open(
      'spec/support/example_files/example_notice_export.csv'
    )
    expect(ingestor).to respond_to(:each)
  end

  it "determines what importer to use for an original source file" do
    Ingestor::WorksImporter::Dispatcher.should_receive(:import)
    Dmca.stub(:create!)

    with_csv_linked_to_source_data(google_default_original_source_data) do |csv_file|
      ingestor = described_class.open(csv_file.path)
      ingestor.import
    end
  end

end
