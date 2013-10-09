require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::DmcaParser do

  context "work descriptions" do
    it "from the first format" do
      work = described_class.new(sample_file).works.first

      expect(work.description).to eq(
        'A computer generated image of a beach/pool
villa, the design of which is the copyright work of Bag of Holding
Co. Ltd.
It is located at http://www.example.com/photo.jpg'
      )
    end

    it "from the second format" do
      work = described_class.new(tertiary_sample_file).works.first

      expect(work.description).to eq( 'Insanity� fitness DVD' )
    end
  end

  it "gets copyrighted_urls" do
    work = described_class.new(sample_file).works.first

    expect(work.copyrighted_urls.map(&:url)).to match_array(
      %w|http://www.example.com/photo.jpg|
    )
  end

  it "gets infringing_urls" do
    work = described_class.new(sample_file).works.first

    expect(work.infringing_urls.map(&:url)).to match_array(
      %w|http://www.example.com/unstoppable.html
http://www.example.com/unstoppable_2.html
http://www.example.com/unstoppable_3.html|
    )
  end

  private

  def sample_file
    'spec/support/example_files/secondary_dmca_notice_source.html'
  end

  def tertiary_sample_file
    'spec/support/example_files/secondary_dmca_notice_source-3.html'
  end
end
