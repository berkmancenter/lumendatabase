require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::DmcaParser do

  it "gets work descriptions" do
    parser = described_class.new(parseable_content)
    expect(parser.description).to eq(
      'A computer generated image of a beach/pool
villa, the design of which is the copyright work of Bag of Holding
Co. Ltd.
It is located at http://www.example.com/photo.jpg'
    )
  end

  it "gets copyrighted_urls" do
    parser = described_class.new(parseable_content)
    expect(parser.copyrighted_urls).to match_array(
      %w|http://www.example.com/photo.jpg|
    )
  end

  it "gets infringing_urls" do
    parser = described_class.new(parseable_content)
    expect(parser.infringing_urls).to match_array(
      %w|http://www.example.com/unstoppable.html
http://www.example.com/unstoppable_2.html
http://www.example.com/unstoppable_3.html|
    )
  end

  private

  def parseable_content
    File.read(
      'spec/support/example_files/secondary_dmca_notice_source.html'
    )
  end
end
