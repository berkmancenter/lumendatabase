require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Youtube::Counterfeit do
  it "has a default recipient" do
    expect(described_class.new('').default_recipient).to eq 'Youtube (Google, Inc.)'
  end

  context "#notice_type" do
    it 'should be Trademark' do
      expect(described_class.new('').notice_type).to eq Trademark
    end
  end

  it 'will handle it' do
    expect(described_class.handles?(counterfeit_notice_path)).to be true
  end

  it 'gets works' do
    first_work = importer.works.first

    infringing_urls = first_work.infringing_urls.map(&:url)

    expect(infringing_urls).to match_array(
      %w|http://www.youtube.com/watch?v=H0r8U-|
    )
    expect(first_work.description).to match /This video show several/
    expect(first_work.copyrighted_urls).to be_empty
  end

  it 'gets entity information' do
    expect(importer.entities[:principal]).to eq "Humboldt SA, Genève"
    expect(importer.entities[:sender]).to eq "Adelaid Bourbou, Internet Unit, The Federation"
  end

  it 'gets mark_registration_number info' do
    expect(importer.mark_registration_number).to eq '12200000'
  end

  private

  def counterfeit_notice_path
    'spec/support/example_files/youtube_counterfeit.html'
  end

  def importer
    described_class.new(counterfeit_notice_path)
  end
end
