require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Youtube::TrademarkB do
  it "has a default recipient" do
    expect(described_class.new('').default_recipient).to eq 'Google, Inc.'
  end

  context "#notice_type" do
    it 'should be Trademark' do
      expect(described_class.new('').notice_type).to eq Trademark
    end
  end

  it 'will handle it' do
    expect(described_class.handles?(trademark_b_notice_path)).to be true
  end

  it 'gets works' do
    first_work = importer.works.first

    infringing_urls = first_work.infringing_urls.map(&:url)

    expect(infringing_urls).to match_array(
        %w|https://www.youtube.com/user/ThisChipmunks|
    )
    expect(first_work.description).to match /Unauthorized Use of Jorge/
    expect(first_work.copyrighted_urls).to be_empty
  end

  it 'gets entity information' do
    expect(importer.entities[:principal]).to eq "Bagdad Productions, LLC"
    expect(importer.entities[:sender]).to eq "Tracy Papagallo, outside counsel"
  end

  it 'gets mark_registration_number info' do
    expect(importer.mark_registration_number).to eq '29350000'
  end

  private

  def trademark_b_notice_path
    'spec/support/example_files/youtube_trademarkcomplaintb.html'
  end

  def importer
    described_class.new(trademark_b_notice_path)
  end
end
