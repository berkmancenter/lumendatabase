class ResultOrdering
  attr_reader :param, :sort_by, :label

  # The param is passed in from the UI; the sort_by is the same information,
  # but in the format used by Elasticsearch; the label is a human-readable
  # representation. It's up to the caller of #new to get the mappings among
  # these right.
  def initialize(param, sort_by, label)
    @param = param
    @sort_by = sort_by
    @label = label
  end

  def self.define(sort_by_param, model_class = Notice)
    model_class::ORDERING_OPTIONS.find { |ordering| ordering.param == sort_by_param } ||
      self.default_ordering
  end

  private

  def self.default_ordering
    ResultOrdering.new('relevancy desc', [:_score, :desc], 'Most Relevant')
  end
end
