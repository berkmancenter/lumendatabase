require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::OtherParser do

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

  private

  def sample_file
    'spec/support/example_files/secondary_other_notice_source.html'
  end

end
