require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Youtube::Defamation do
  it "has a default recipient" do
    expect(described_class.new('').default_recipient).to eq 'Youtube (Google, Inc.)'
  end

  context "#notice_type" do
    it 'should be Defamation' do
      expect(described_class.new('').notice_type).to eq Defamation
    end
  end

  it 'will handle it' do
    expect(described_class.handles?(defamation_notice_path)).to be true
  end

  it 'gets works' do
    first_work = importer.works.first

    infringing_urls = first_work.infringing_urls.map(&:url)

    expect(infringing_urls).to match_array(
      %w|https://www.youtube.com/watch?v=7uC2cJz0 https://www.youtube.com/watch?v=lRu8rSY|
    )
    expect(first_work.description).to match /Narrator Joe Schmoe/
    expect(first_work.copyrighted_urls).to be_empty
  end

  it 'gets entity information' do
    expect(importer.entities[:principal]).to eq 'FlimmComm Wireless'
    expect(importer.entities[:sender]).to eq 'Timothy H. Fellpee, Attorney for FlimmComm Wireless'
  end

  private

  def defamation_notice_path
    'spec/support/example_files/youtube_defamation.html'
  end

  def importer
    described_class.new(defamation_notice_path)
  end
end
