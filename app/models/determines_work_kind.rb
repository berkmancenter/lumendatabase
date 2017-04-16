class DeterminesWorkKind
  def initialize(work)
    @work = work
  end

  def kind
    classifier = Classifier.new
    classifier.classify(work.description, 3)
    classifier.classify_each(work.copyrighted_urls.map(&:url), 5)
    classifier.classify_each(work.infringing_urls.map(&:url), 1)

    classifier.best
  end

  private

  attr_reader :work

  class Classifier
    PATTERNS = {
      software: /\.rar\s*$/i,
      image: /(photo|image)s?/i,
      music: /artist\s+name|music|mp3|aac|album|flac|song/i,
      movie: /mp4|mov|movies|dvd|xvid|rip|bluray/i,
      book: /page|novel|book|epub|kindle/i
    }.freeze

    def initialize
      @results = Hash.new { |hash, key| hash[key] = 0 }
      @results[:unknown] = 0
    end

    def classify_each(values, weight)
      values.each { |value| classify(value, weight) }
    end

    def classify(value, weight)
      PATTERNS.each do |kind, pattern|
        results[kind] += weight if value =~ pattern
      end
    end

    def best
      results.max_by { |_, weight| weight }.first
    end

    private

    attr_reader :results
  end
end
