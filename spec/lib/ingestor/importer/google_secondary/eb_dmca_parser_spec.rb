require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::EbDMCAParser do

  it "has a default_recipient" do
    expect(described_class.new('').default_recipient).to eq 'Google, Inc.'
  end

  it "gets entity information" do
    expect(described_class.new(sample_file).entities).to eq({
      sender: 'first name last name',
      principal: 'Vsjrh32e8v13Mor',
      recipient: 'Google, Inc.'
    })
  end

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
      'http://example.com/copyrighted_3',
      'http://example.com/copyrighted_4'
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
