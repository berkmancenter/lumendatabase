require 'spec_helper'
require 'ingestor'

describe Ingestor::Importer::Twitter do

  it "has a default_recipient" do
    expect(described_class.new('').default_recipient).to eq 'Twitter'
  end

  context ".handles?" do
    it "returns true for twitter files" do
      expect(described_class).to handle(
        "spec/support/example_files/original_twitter_notice_source.txt"
      )
    end

    it "returns false for non twitter files" do
      expect(described_class).not_to handle(
        "spec/support/example_files/original_notice_source.txt"
      )
    end
  end

  context "#parse_entities" do
    it "parses entities" do
      importer = described_class.new(
        "spec/support/example_files/original_twitter_notice_source.txt," \
        "spec/support/example_files/original_twitter_notice_source.html"
      )

      expect(importer.entities[:sender]).to eq 'Jim Smith'
      expect(importer.entities[:principal]).to eq 'Some Copyright Owner'
    end
  end

  context "#parse_works" do
    it "parses the correct work descriptions" do
      importer = described_class.new(
        "spec/support/example_files/original_twitter_notice_source.txt," \
        "spec/support/example_files/original_twitter_notice_source.html"
      )

      descriptions = importer.works.map(&:description).flatten

      expect(descriptions).to match_array([
        'Copyrighted Japanese translated or raw anime/manga to MX International',
        'Copyrighted Japanese translated or raw anime/manga to MX International',
      ])
    end

    it "parses the correct infringing urls" do
      importer = described_class.new(
        "spec/support/example_files/original_twitter_notice_source.txt," \
        "spec/support/example_files/original_twitter_notice_source.html"
      )

      urls = importer.works.map(&:infringing_urls).flatten.map(&:url)

      expect(urls).to match_array([
        'https://twitter.com/NoMatter/status/12345',
        'https://twitter.com/NoMatter/status/4567',
      ])
    end
  end
end
