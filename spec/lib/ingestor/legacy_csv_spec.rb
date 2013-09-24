require 'spec_helper'
require 'ingestor'

describe Ingestor::LegacyCsv do

  before do
    @error_handler = double.as_null_object
    described_class::ErrorHandler.stub(:new).and_return(@error_handler)

    @attribute_mapper = double("AttributeMapper")
    @attribute_mapper.stub(:exclude?).and_return(false)
    @attribute_mapper.stub(:notice_type).and_return(Dmca)
    @attribute_mapper.stub(:mapped).and_return({})
    described_class::AttributeMapper.stub(:new).and_return(@attribute_mapper)
  end

  it "instantiates the correct notice type based on AttributeMapper" do
    @attribute_mapper.stub(:notice_type).and_return(Trademark)
    Trademark.should_receive(:create!).at_least(:once).and_return(Trademark.new)

    new_importer.import
  end

  def new_importer
    sample_file = "spec/support/example_files/example_notice_export.csv"

    described_class.new(sample_file).tap do |importer|
      importer.logger.level = ::Logger::FATAL
    end
  end

end
