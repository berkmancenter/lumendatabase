require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Youtube::OtherLegal do
  it "has a default recipient" do
    expect(described_class.new('').default_recipient).to eq 'Google, Inc.'
  end

  context "#notice_type" do
    it 'should be Other' do
      expect(described_class.new('').notice_type).to eq Other
    end
  end

  it 'will handle it' do
    expect(described_class.handles?(other_legal_notice_path)).to be true
  end

  it 'gets works' do
    first_work = importer.works.first

    infringing_urls = first_work.infringing_urls.map(&:url)

    expect(infringing_urls).to match_array(
      %w|https://www.youtube.com/watch?v=xszr9lUlPE8
https://www.youtube.com/watch?v=w2-DjJ
https://www.youtube.com/watch?v=PlsCEe|
    )
    expect(first_work.description).to match /I'm tired to send messages/
    expect(first_work.copyrighted_urls).to be_empty
  end

  it 'gets entity information' do
    expect(importer.entities[:principal]).to eq "Peter Dancer"
    expect(importer.entities[:sender]).to eq "PeterDancer"
  end

  private

  def other_legal_notice_path
    'spec/support/example_files/youtube_otherlegal.html'
  end

  def importer
    described_class.new(other_legal_notice_path)
  end
end
