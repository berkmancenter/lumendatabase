require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::BloggerParser do

  it "handles the correct files" do
    expect(described_class).to handle(sample_file)
  end

  it "has a default recipient" do
    expect(described_class.new('').default_recipient).to eq 'Google, Inc.'
  end

  it "gets entity information" do
    entities = described_class.new(sample_file).entities
    expect(entities).to eq(
      {
        sender: 'Sébastien Forte',
        principal: 'No Time Records / MERCURY',
        recipient: 'Google, Inc.'
      }
    )
  end

  it "gets work descriptions" do
    work = described_class.new(sample_file).works.first

    expect(work.description).to eq(
      "Malgré les signalements le site est toujours en  \r
ligne, nous demandons la suppréssion immédiate du site web ! (sons, albums  \r
& clips en téléchargements illégaux)"
    )
  end

  it "gets infringing_urls" do
    work = described_class.new(sample_file).works.first

    expect(work.infringing_urls.map(&:url)).to match_array([
      'http://www.example.com/infringing_1.html',
      'http://www.example.com/infringing_2.html',
      'http://www.example.com/infringing_3.html',
      'http://www.example.com/infringing_4.html',
      'http://www.example.com/infringing_5.html',
      'http://www.example.com/infringing_6.html',
    ])
  end

  private

  def sample_file
    'spec/support/example_files/blogger_dmca_source.txt'
  end

end
