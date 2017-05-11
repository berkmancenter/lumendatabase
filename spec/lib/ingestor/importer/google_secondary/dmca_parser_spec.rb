require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary::DMCAParser do

  it "has a default_recipient" do
    expect(described_class.new('').default_recipient).to eq 'Google, Inc.'
  end

  context "from the first format" do

    it "parses entities" do
      expect(described_class.new(sample_file).entities).to eq({
        sender: 'Brian Schmoe',
        principal: 'Bag of Holding Co. Ltd',
        recipient: 'Google, Inc.'
      })
    end

    it "parses work descriptions" do
      work = described_class.new(sample_file).works.first

      expect(work.description).to eq(
        'A computer generated image of a beach/pool
villa, the design of which is the copyright work of Bag of Holding
Co. Ltd.
It is located at http://www.example.com/photo.jpg'
      )
    end

    it "parses copyrighted_urls" do
      work = described_class.new(sample_file).works.first

      expect(work.copyrighted_urls.map(&:url)).to match_array(
        %w|http://www.example.com/photo.jpg
      http://www.example.com/TheResidences/Villa.htm|
      )
    end

    it "parses infringing_urls" do
      work = described_class.new(sample_file).works.first

      expect(work.infringing_urls.map(&:url)).to match_array(
        %w|http://www.example.com/unstoppable.html
http://www.example.com/unstoppable_2.html
http://www.example.com/unstoppable_3.html|
      )
    end
  end

  context "from the secondary format" do
    it "from the second format" do
      work = described_class.new(tertiary_sample_file).works.first

      expect(work.description).to eq( 'Insanity� fitness DVD' )
    end

    it "parses infringing_urls" do
      work = described_class.new(tertiary_sample_file).works.first

      expect(work.infringing_urls.map(&:url)).to match_array(
         [
           "http://www.example.co.uk/product473971_3208393.aspx",
           "http://www.example.com/auction_details.php?auction_id=1000003480",
           "http://www.example.com/catalogsearch/result/?q=shaun+t+insanity+&x=0&y=0",
           "http://www.example.com/index.aspx?pageid=410078&prodid=3970894&rw=1",
           "http://www.example.com/shaun-ts-insanity-workout-deluxe-package-13dvd-p-3.html",
           "http://www.example.com/stores/GMTech/item?lid=19316903&source=Vendio:Google%20Product%20Search",
           "http://www.example.net/insanity-workout-a-60-day-workout-with-shaun-t-p-7.html"
         ]
      )
    end
  end

  private

  def sample_file
    'spec/support/example_files/secondary_dmca_notice_source.html'
  end

  def tertiary_sample_file
    'spec/support/example_files/secondary_dmca_notice_source-3.html'
  end
end
