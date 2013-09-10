require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::GoogleSecondary do

  it "gets works" do
    expect(works_from_exported_file.length).to eq 1
  end

  it "can get work descriptions" do
    work = works_from_exported_file.first
    expect(work.description.length).to be > 0
  end

  it "can get infringing_urls" do
    work = works_from_exported_file.first
    expect(work.infringing_urls.length).to eq 3
  end

  it "can get copyrighted_urls" do
    work = works_from_exported_file.first
    expect(work.copyrighted_urls.length).to eq 1
  end

  context "uses the appropriate works metadata parser" do
    %w/Other Dmca/.each do |sub_type|
      it "for a #{sub_type} input file" do
        source_file = "spec/support/example_files/secondary_#{sub_type.downcase}_notice_source.html"
        content = File.read(source_file)
        parser_class = "Ingestor::Importer::GoogleSecondary::#{sub_type}Parser".constantize
        parser = parser_class.new(content)

        parser_class.should_receive(:new).with(content).and_return(parser)

        works_from_exported_file(source_file)
      end
    end
  end

  private

  def works_from_exported_file(
    file = 'spec/support/example_files/secondary_dmca_notice_source.html'
  )
    described_class.new(file).works
  end
end
