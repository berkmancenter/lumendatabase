class DeterminesWorkKind
  def initialize(work)
    @primary_urls = work.copyrighted_urls.map(&:url)
    @secondary_urls = work.infringing_urls.map(&:url)
    @results = { unknown: 0 }
  end

  def kind
    classify_urls(@primary_urls, 5)
    classify_urls(@secondary_urls, 1)

    pick_result
  end

  private

  def pick_result
    @results.max_by{|kind, weight| weight}.first
  end

  def classify_urls(urls, weight)
    urls.each do |url|
      url_classifier = ClassifyUrl.new(url, weight)
      @results.merge!(url_classifier.classify) do |key, old_value, new_value|
        old_value + new_value
      end
    end
  end

  class ClassifyUrl
    PATTERNS = {
      music: %r{mp3|aac|album|flac|song}i,
      movie: %r{mp4|mov|movies|dvd|xvid|rip|bluray}i,
      book: %r{page|novel|book|epub|kindle}i
    }

    def initialize(url, weight)
      @url = url
      @weight = weight || 1
    end

    def classify
      classification_results = {}
      PATTERNS.each do |kind, pattern|
        if @url =~ pattern
          classification_results[kind] = @weight
        end
      end
      classification_results
    end
  end
end
