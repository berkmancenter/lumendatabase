require 'spec_helper'
require 'ingestor'

describe Ingestor::LegacyCsv do

  before do
    described_class::ErrorHandler.stub(:new).
      and_return(double.as_null_object)
  end

  it "instantiates the correct notice type based on AttributeMapper" do
    attribute_mapper = double("AttributeMapper")
    attribute_mapper.stub(:notice_type).and_return(Trademark)
    attribute_mapper.stub(:mapped).and_return({})
    described_class::AttributeMapper.stub(:new).and_return(attribute_mapper)
    Trademark.should_receive(:create!).at_least(:once).and_return(Trademark.new)
    importer = described_class.new(
      "spec/support/example_files/example_notice_export.csv"
    )
    importer.logger.level = ::Logger::FATAL

    importer.import
  end

end
