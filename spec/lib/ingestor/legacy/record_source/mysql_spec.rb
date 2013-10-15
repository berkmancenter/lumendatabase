require 'spec_helper'
require 'ingestor'

describe Ingestor::Legacy::RecordSource::Mysql do

  before do
    connection_double = double("Mysql connection")
    results = double(
      "Mysql query results",
      first:  { 'foo' => 1, 'bar' => 2 } 
    )
    connection_double.stub(:query).and_return(results)
    Mysql2::Client.stub(:new).and_return(connection_double)

    @record_source = described_class.new('select * from tNotice', 'test_records')
  end

  context ".headers" do
    it "should be an array" do

      expect(@record_source.headers).to eq ['foo', 'bar']
    end
  end

  it "should have a name" do
    expect(@record_source.name).to eq 'test_records'
  end

  it "should have a default base_directory" do
    expect(@record_source.base_directory).to eq 'imports'
  end
end
