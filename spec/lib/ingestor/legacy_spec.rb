require 'spec_helper'
require 'ingestor'

describe Ingestor::Legacy do

  before do
    @error_handler = double.as_null_object
    described_class::ErrorHandler.stub(:new).and_return(@error_handler)

    @attribute_mapper = double("AttributeMapper")
    @attribute_mapper.stub(:exclude?).and_return(false)
    @attribute_mapper.stub(:notice_type).and_return(DMCA)
    @attribute_mapper.stub(:mapped).and_return({})
    described_class::AttributeMapper.stub(:new).and_return(@attribute_mapper)
  end

  it "instantiates the correct notice type based on AttributeMapper" do
    @attribute_mapper.stub(:notice_type).and_return(Trademark)
    Trademark.should_receive(:create!).at_least(:once).and_return(Trademark.new)

    importer.import
  end

  it "attempts to find a notice by original_notice_id before importing" do
    dmca = DMCA.new

    existing_notice_ids.each do |original_notice_id|
      Notice.should_receive(:where).with(original_notice_id: original_notice_id).once.and_return(dmca)
    end

    DMCA.should_not_receive(:create!)

    importer.import
  end

  def importer
    sample_file = "spec/support/example_files/example_notice_export.csv"
    record_source = Ingestor::Legacy::RecordSource::CSV.new(sample_file)

    described_class.new(record_source).tap do |importer|
      importer.logger.level = ::Logger::FATAL
    end
  end

  def existing_notice_ids
    File.open("spec/support/example_files/example_notice_export.csv").map do |line|
      line.split(',').first
    end[1,20]
  end
end
