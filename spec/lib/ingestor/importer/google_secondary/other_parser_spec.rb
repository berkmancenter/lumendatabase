require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::OtherParser do

  it "gets work descriptions" do
    parser = described_class.new(parseable_content)
    expect(parser.description).to eq(
'diffamazione e violazione della privacy
foobar'
    )
  end

  it "gets copyrighted_urls" do
    parser = described_class.new(parseable_content)
    expect(parser.copyrighted_urls).to be_empty
  end

  it "gets infringing_urls" do
    parser = described_class.new(parseable_content)
    expect(parser.infringing_urls).to match_array(
      %w|http://www.example.com/asdfasdf
http://www.example.com/infringing|
    )
  end

  private

  def parseable_content
    File.read(
      'spec/support/example_files/secondary_other_notice_source.html'
    )
  end
end
