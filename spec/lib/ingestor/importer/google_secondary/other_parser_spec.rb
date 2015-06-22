require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::OtherParser do
  let(:sample_file) do
    'spec/support/example_files/secondary_other_notice_source.html'
  end

  let(:redaction_file) do
    'spec/support/example_files/secondary_other_redaction_notice_source.html'
  end

  it "has a default_recipient" do
    expect(described_class.new('').default_recipient).to eq 'Google, Inc.'
  end

  it "gets entities" do
    expect(described_class.new(sample_file).entities).to eq({
      sender: 'REDACTED',
      principal: 'FooCorp'
    })
  end

  it "gets work descriptions" do
    work = described_class.new(sample_file).works.first

    expect(work.description).to eq(
'diffamazione e violazione della privacy
foobar'
    )
  end

  it "gets copyrighted_urls" do
    work = described_class.new(sample_file).works.first

    expect(work.copyrighted_urls.map(&:url)).to be_empty
  end

  it "gets infringing_urls" do
    work = described_class.new(sample_file).works.first

    expect(work.infringing_urls.map(&:url)).to match_array(
      %w|http://www.example.com/asdfasdf
http://www.example.com/infringing|
    )
  end

  it "redacts work descriptions" do
    work = described_class.new(redaction_file).works.first

    expect(work.description).to eq(
'Someone (unknown) has got hold of my personal details  
and posted images with my name and my cell phone number on flickr. I have  
contacted flickr but please help me by removing the link if possible. i am  
very concerned about this as you can imagine. My name and address [REDACTED],  
[REDACTED] have been posted. http://[REDACTED].[REDACTED]-[REDACTED].com [REDACTED]'
    )
  end

  it "redacts copyrighted_urls" do
    work = described_class.new(redaction_file).works.first

    expect(work.copyrighted_urls.map(&:url)).to match_array(
      ['http://[REDACTED].[REDACTED]-[REDACTED].com']
    )
  end

  it "redacts infringing_urls" do
    work = described_class.new(redaction_file).works.first

    expect(work.infringing_urls.map(&:url)).to match_array(
      %w|http://www.flickr.com/photos/[REDACTED]/89538824@N03/8152247706/|
    )
  end
end
