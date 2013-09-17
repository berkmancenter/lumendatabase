require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Google do

  context "#handles?" do
    it "should not inspect binary files" do
      file_double = double('File handle')

      File.stub(:open) do |&block|
        block.yield file_double
      end

      file_double.should_not_receive(:grep)
      described_class.handles?('spec/support/example_files/original.jpg')
    end
  end

  context "#notice_type" do
    it "should be Dmca" do
      expect(described_class.new('').notice_type).to eq Dmca
    end
  end

  context "complete source files" do
    it "gets works" do
      expect(works_from_complete_file.length).to eq 2
    end

    it "can get work descriptions" do
      descriptions = works_from_complete_file.map(&:description)

      expect(descriptions).to match_array(
        [
          'Artist Name:Rick Astley
Track Name: Flipy The Bear',
          'Video and Image series produced by Copyright Owner LLC.',
      ]
      )
    end

    it "can get copyrighted urls" do
      works = works_from_complete_file

      expect(works[0].copyrighted_urls.map(&:url)).to match_array(
        %w|http://example.com/original_work_url
      http://example.com/original_work_url_again|
      )
      expect(works[1].copyrighted_urls.map(&:url)).to match_array(
        %w|http://example.com/original_work_url
      http://example.com/original_work_url_dos|
      )
    end

    it "can get infringing urls" do
      works = works_from_complete_file

      expect(works[0].infringing_urls.map(&:url)).to match_array(
        %w|http://infringing.example.com/url_0
         http://infringing.example.com/url_1|
      )
      expect(works[1].infringing_urls.map(&:url)).to match_array(
        %w|http://infringing.example.com/url_second_0
         http://infringing.example.com/url_second_1|
      )
    end
  end

  context "partial source files" do
    it "gets works" do
      expect(works_from_partial_file.length).to eq 2
    end

    it "can be parsed correctly" do
      works = works_from_partial_file

      expect(works[0].copyrighted_urls.map(&:url)).to eq []
      expect(works[0].infringing_urls.map(&:url)).to match_array(
        %w|http://infringing.example.com/url_0
         http://infringing.example.com/url_1|
      )

      expect(works[1].copyrighted_urls.map(&:url)).to match_array(
        %w|http://example.com/original_work_url
         http://example.com/original_work_url_dos|
      )
      expect(works[1].infringing_urls.map(&:url)).to eq []
    end
  end

  private

  def works_from_complete_file
    described_class.new('spec/support/example_files/original_notice_source.txt').works
  end

  def works_from_partial_file
    described_class.new('spec/support/example_files/partial_url_notice_source.txt').works
  end
end
