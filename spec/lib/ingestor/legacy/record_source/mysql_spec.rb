require 'spec_helper'
require 'ingestor'

describe Ingestor::Legacy::RecordSource::Mysql do

  context ".headers" do
    it "should be an array" do
      expect(mysql_record_source.headers).to eq(
        ['foo', 'bar', 'OriginalFilePath', 'SupportingFilePath']
      )
    end
  end

  it "should have a name" do
    expect(mysql_record_source.name).to eq 'test_records'
  end

  it "should fix file paths when files don't exist" do
    mysql_record_source.each do |row|
      expect(row['OriginalFilePath']).to eq ''
      expect(row['SupportingFilePath']).to eq ''
    end
  end

  it "should have a default base_directory" do
    expect(mysql_record_source.base_directory).to eq 'imports'
  end

  private

  def mysql_record_source
    connection_double = double("Mysql connection")
    allow(connection_double).to receive(:query).and_return([
      'foo' => 1, 'bar' => 2, 'OriginalFilePath' => 'foo.html',
      'SupportingFilePath' => 'bar.html']
    )
    allow(Mysql2::Client).to receive(:new).and_return(connection_double)

    described_class.new('select * from tNotice', 'test_records')
  end

end
