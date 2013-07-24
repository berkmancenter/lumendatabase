require 'spec_helper'

describe DeterminesWorkKind do
  it "returns unknown when a URL can't be classified" do
    determiner = described_class.new(
      ['http://www.example.com/foo.something'], []
    )
    expect(determiner.kind).to be :unknown
  end

  context 'primary urls' do
    %w(mp3 aac album flac MP3 song).each do |string|
      it "classifies a primary URL including #{string} as music" do
        determiner = described_class.new(
          ["http://www.example.com/foo.#{string}"], []
        )
        expect(determiner.kind).to be :music
      end
    end

    %w( mp4 mov movies dvd xvid rip bluray ).each do |string|
      it "classifies a primary URL including #{string} as a movie" do
        determiner = described_class.new(
          ["http://www.example.com/foo.#{string}"], []
        )
        expect(determiner.kind).to be :movie
      end
    end

    %w( page novel book epub kindle ).each do |string|
      it "classifies a primary URL including #{string} as a book" do
        determiner = described_class.new(
          ["http://www.example.com/foo.#{string}"], []
        )
        expect(determiner.kind).to be :book
      end
    end
  end

  context 'infringing urls' do
    it "classifies as music" do
      determiner = described_class.new(
        ["http://www.example.com/foo"],
        [
          'http://mp3.com/asfdasdf',
          'http://example.com/aac',
          'http://example.com/flac',
          'http://example.com'
        ]
      )
      expect(determiner.kind).to be :music
    end

    it "classifies as a movie" do
      determiner = described_class.new(
        ["http://www.example.com/foo"],
        [
          'http://mp3.com/dvd',
          'http://example.com/torrent/xvid',
          'http://example.com/bluray',
          'http://example.com'
        ]
      )
      expect(determiner.kind).to be :movie
    end

    it "classifies as a book" do
      determiner = described_class.new(
        ["http://www.example.com/foo"],
        [
          'http://mp3.com/book',
          'http://example.com/ebook/xvid',
          'http://example.com/novel',
          'http://example.com/kindle'
        ]
      )
      expect(determiner.kind).to be :book
    end
  end
end
