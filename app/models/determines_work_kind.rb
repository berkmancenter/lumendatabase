class DeterminesWorkKind
  def initialize(work)
    @work = work
  end

  def kind
    classifier = Classifier.new
    classifier.classify(work.description, 3)
    classifier.classify_all(work.copyrighted_urls.map(&:url), 5)
    classifier.classify_all(work.infringing_urls.map(&:url), 1)

    classifier.best
  end

  private

  attr_reader :work

  class Classifier
    PATTERNS = {
      software: %r{\.rar\s*$}i,
      image: %r{(photo|image)s?}i,
      music: %r{artist\s+name|music|mp3|aac|album|flac|song}i,
      movie: %r{mp4|mov|movies|dvd|xvid|rip|bluray}i,
      book: %r{page|novel|book|epub|kindle}i
    }

    def initialize
      @results = Hash.new { |hash,key| hash[key] = 0 }
      @results[:unknown] = 0
    end

    def classify_all(values, weight)
      values.each do |value|
        classify(value, weight)
      end
    end

    def classify(value, weight)
      PATTERNS.each do |kind,pattern|
        if value =~ pattern
          results[kind] += weight
        end
      end
    end

    def best
      results.max_by { |_,weight| weight }.first
    end

    attr_reader :results

  end
end
