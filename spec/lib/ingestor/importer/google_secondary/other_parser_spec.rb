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
      sender: 'dan smith',
      principal: 'FooCorp'
    })
  end

  it "gets work descriptions" do
    work = described_class.new(sample_file).works.first

    expect(work.description).to eq(
"#{Ingestor::Importer::GoogleSecondary::RedactedContent::QUOTE_PREAMBLE.strip}
violazione della privacy
boofar
#{Ingestor::Importer::GoogleSecondary::RedactedContent::EXPLAIN_PREAMBLE.strip}
diffamazione e violazione della privacy
foobar"
    )
  end

  it "gets work description_originals" do
    work = described_class.new(sample_file).works.first

    expect(work.description_original).to eq(
"#{Ingestor::Importer::GoogleSecondary::RedactedContent::QUOTE_PREAMBLE.strip}
violazione della privacy
boofar
#{Ingestor::Importer::GoogleSecondary::RedactedContent::EXPLAIN_PREAMBLE.strip}
diffamazione e violazione della privacy
foobar"
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
"#{Ingestor::Importer::GoogleSecondary::RedactedContent::QUOTE_PREAMBLE.strip}
[REDACTED] child abuser bristol durham real gay deep  
ass - Flickr
Also...[REDACTED]
And [REDACTED]?
And [REDACTED]?
#{Ingestor::Importer::GoogleSecondary::RedactedContent::EXPLAIN_PREAMBLE.strip}
Someone (unknown) has got hold of my personal details  
and posted images with my name and my cell phone number on flickr. I have  
contacted flickr but please help me by removing the link if possible. i am  
very concerned about this as you can imagine. My name and address [REDACTED] have been posted. http://[REDACTED].com [REDACTED] and [REDACTED]."
    )
  end

  it "preserves work description_originals" do
    work = described_class.new(redaction_file).works.first

    expect(work.description_original).to eq(
"#{Ingestor::Importer::GoogleSecondary::RedactedContent::QUOTE_PREAMBLE.strip}
Johnny Public child abuser bristol durham real gay deep  
ass - Flickr
Also...Rights Holder
And Johnny Public * Blacksmith-Fisherman vOn - Helsing +Formula 3451 Racing?
And Johnny Public Blacksmith*Fisherman vOn-Helsing Formula+ 34 . 51 Racing?
#{Ingestor::Importer::GoogleSecondary::RedactedContent::EXPLAIN_PREAMBLE.strip}
Someone (unknown) has got hold of my personal details  
and posted images with my name and my cell phone number on flickr. I have  
contacted flickr but please help me by removing the link if possible. i am  
very concerned about this as you can imagine. My name and address Public,  
Johnny have been posted. http://johnny.public.public-johnny.com Johnny,  
Public and johnnypublic.public^publicpublic1johnnyjohnny johnnyjohnny."
    )
  end

  it "redacts copyrighted_urls" do
    work = described_class.new(redaction_file).works.first
    work.save!

    expect(work.copyrighted_urls.map(&:url)).to match_array(
      ['http://[REDACTED].com']
    )
  end

  it "preserves url_original for copyrighted_urls" do
    work = described_class.new(redaction_file).works.first
    work.save!

    expect(work.copyrighted_urls.map(&:url_original)).to match_array(
      ['http://johnny.public.public-johnny.com']
    )
  end

  it "redacts infringing_urls" do
    work = described_class.new(redaction_file).works.first
    work.save!

    expect(work.infringing_urls.map(&:url)).to match_array(
      %w|http://www.flickr.com/photos/[REDACTED]/89538824@N03/8152247706/|
    )
  end

  it "preserves url_original for infringing_urls" do
    work = described_class.new(redaction_file).works.first
    work.save!

    expect(work.infringing_urls.map(&:url_original)).to match_array(
      %w|http://www.flickr.com/photos/johnny_public/89538824@N03/8152247706/|
    )
  end

  it "redacts copyrighted_urls that already exist" do
    create(:copyrighted_url, url: 'http://johnny.public.public-johnny.com')
    work = described_class.new(redaction_file).works.first
    work.save!

    expect(work.copyrighted_urls.map(&:url)).to match_array(
      ['http://[REDACTED].com']
    )
  end

  it "redacts infringing_urls that already exist" do
    create(:infringing_url, url: 'http://www.flickr.com/photos/johnny_public/89538824@N03/8152247706/')
    work = described_class.new(redaction_file).works.first
    work.save!

    expect(work.infringing_urls.map(&:url)).to match_array(
      ['http://www.flickr.com/photos/[REDACTED]/89538824@N03/8152247706/']
    )
  end
end
