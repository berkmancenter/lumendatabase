require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Youtube::TrademarkD do
  it "has a default recipient" do
    expect(described_class.new('').default_recipient).to eq 'Youtube (Google, Inc.)'
  end

  context "#notice_type" do
    it 'should be Trademark' do
      expect(described_class.new('').notice_type).to eq Trademark
    end
  end

  it 'will handle it' do
    expect(described_class.handles?(trademark_d_notice_path)).to be true
  end

  it 'gets works' do
    first_work = importer.works.first

    infringing_urls = first_work.infringing_urls.map(&:url)

    expect(infringing_urls).to match_array(
      %w|http://www.youtube.com/watch?v=iPK
       http://www.youtube.com/watch?v=6HG
       http://www.youtube.com/watch?v=FzH|
    )
    expect(first_work.description).to match /These three videos are/
    expect(first_work.copyrighted_urls).to be_empty
  end

  it 'gets entity information' do
    expect(importer.entities[:principal]).to eq "BEST EXAMPLE PEST DEFENSE, INC."
    expect(importer.entities[:sender]).to eq "Jonathan Clucker Rebar, Attorney for Best Example Pest Defense, Inc."
  end

  private

  def trademark_d_notice_path
    'spec/support/example_files/youtube_trademarkcomplaintd.html'
  end

  def importer
    described_class.new(trademark_d_notice_path)
  end
end
