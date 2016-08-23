require 'spec_helper'

describe DeterminesWorkKind, type: :model do
  context "determining by copyrighted urls" do
    it "returns unknown for unknown patterns" do
      work = Work.new(copyrighted_urls_attributes: [
        { url: 'http://www.example.com/foo.something' }
      ])

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :unknown
    end

    %w( mp3 aac album flac MP3 song ).map do |ext|
      it "classifies #{ext} extensions as music" do
        work = Work.new(copyrighted_urls_attributes: [
          { url: "http://www.example.com/foo.#{ext}" }
        ])

        determiner = described_class.new(work)

        expect(determiner.kind).to eq :music
      end
    end

    %w( mp4 mov movies dvd xvid rip bluray ).map do |ext|
      it "classifies #{ext} as movies" do
        work = Work.new(copyrighted_urls_attributes: [
          { url: "http://www.example.com/foo.#{ext}" }
        ])

        determiner = described_class.new(work)

        expect(determiner.kind).to eq :movie
      end
    end

    %w( page novel book epub kindle ).map do |ext|
      it "classifies #{ext} as books" do
        work = Work.new(copyrighted_urls_attributes: [
          { url: "http://www.example.com/foo.#{ext}" }
        ])

        determiner = described_class.new(work)

        expect(determiner.kind).to eq :book
      end
    end

    it "classifies .rar extensions as software" do
      work = Work.new(copyrighted_urls_attributes: [
        { url: "http://www.example.com/foo.rar" }
      ])

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :software
    end

    it "does not see sample 'rar' as an extension" do
      work = Work.new(copyrighted_urls_attributes: [
        { url: "http://www.harard.com/foo.something" }
      ])

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :unknown
    end

    %w( photos images ).each do |phrase|
      it "sees the phrase '#{phrase}' as images" do
        work = Work.new(
          copyrighted_urls_attributes: [
            { url: "http://www.harard.com/#{phrase}" }
          ]
        )

        determiner = described_class.new(work)

        expect(determiner.kind).to eq :image
      end
    end
  end

  context "infringing urls" do
    it "classifies as music" do
      work = Work.new(
        copyrighted_urls_attributes: [
         { url: "http://www.example.com/foo" }
        ],
        infringing_urls_attributes: [
          { url: 'http://mp3.com/asfdasdf' },
          { url: 'http://example.com/aac' },
          { url: 'http://example.com/flac' },
          { url: 'http://example.com' }
        ]
      )

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :music
    end

    it "classifies as a movie" do
      work = Work.new(
        copyrighted_urls_attributes: [
         { url: "http://www.example.com/foo" }
        ],
        infringing_urls_attributes: [
          { url: 'http://mp3.com/dvd' },
          { url: 'http://example.com/torrent/xvid' },
          { url: 'http://example.com/bluray' },
          { url: 'http://example.com' }
        ]
      )

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :movie
    end

    it "classifies as a book" do
      work = Work.new(
        copyrighted_urls_attributes: [
          { url: "http://www.example.com/foo" }
        ],
        infringing_urls_attributes: [
          { url: 'http://mp3.com/book' },
          { url: 'http://example.com/ebook/xvid' },
          { url: 'http://example.com/novel' },
          { url: 'http://example.com/kindle' }
        ]
      )

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :book
    end
  end

  context "by description" do
    %w( Artist\ Name music ).each do |description|
      it "sees #{description} in the description as music" do
        work = Work.new(description: "Foo #{description} bar")

        determiner = described_class.new(work)

        expect(determiner.kind).to eq :music
      end
    end
  end

  context "weighting" do
    it "gives more weight to copyrighted_urls" do
      work = Work.new(
        copyrighted_urls_attributes: [
          { url: "http://www.example.com/foo.mp3" }
        ],
        infringing_urls_attributes: [
          { url: "http://www.example.com/foo.mp4" },
          { url: "http://www.example.com/foo.mov" }
        ]
      )

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :music
    end

    it "gives description more weight than infringing urls" do
      work = Work.new(
        description: "Awesome mp3",
        infringing_urls_attributes: [
          { url: "http://www.example.com/foo.mp4" },
          { url: "http://www.example.com/foo.mov" }
        ]
      )

      determiner = described_class.new(work)

      expect(determiner.kind).to eq :music

    end
  end
end
