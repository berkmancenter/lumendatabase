require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::EbDmcaParser do

  it "gets work descriptions" do
    work = described_class.new(sample_file).works.first

    expect(work.description).to eq(
      "êîíòðîëüíûå, <a  \r
href=\"http://example.com/copyrighted_1\">free amateur   \r
movies</a>, [url=\"http://example.com/copyrighted_2\"]free  \r
amateur  movies[/url], http://example.com/copyrighted_3 sybille  \r
some work,  pplei,"
    )
  end

  it "gets copyrighted_urls" do
    work = described_class.new(sample_file).works.first

    expect(work.copyrighted_urls.map(&:url)).to match_array([
      'http://example.com/copyrighted_1',
      'http://example.com/copyrighted_2',
      'http://example.com/copyrighted_3'
    ])
  end

  it "gets infringing_urls" do
    work = described_class.new(sample_file).works.first

    expect(work.infringing_urls.map(&:url)).to match_array([
      'http://example.com/infringing_1',
      'http://example.com/infringing_2',
      'http://example.com/infringing_3'
    ])
  end

  private

  def sample_file
    'spec/support/example_files/eb_dmca_source.txt'
  end
end
