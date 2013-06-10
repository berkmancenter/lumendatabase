class DeterminesWorkKind
  def initialize(primary_url, secondary_urls)
    @primary_url = primary_url
    @secondary_urls = secondary_urls
    @results = { unknown: 0 }
  end

  def kind
    classify_url(@primary_url, 5)

    @secondary_urls.each do|url|
      classify_url(url, 1)
    end

    pick_result
  end

  private

  def pick_result
    @results.max_by{|kind, weight| weight}.first
  end


  def classify_url(url, weight)
    url_classifier = ClassifyUrl.new(url, weight)
    @results.merge!(url_classifier.classify) do |key, old_value, new_value|
      old_value + new_value
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
