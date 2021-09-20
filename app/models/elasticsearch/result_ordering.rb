class ResultOrdering
  attr_reader :param, :sort_by, :label, :default

  # The param is passed in from the UI; the sort_by is the same information,
  # but in the format used by Elasticsearch; the label is a human-readable
  # representation. It's up to the caller of #new to get the mappings among
  # these right.
  def initialize(param, sort_by, label, default = false)
    @param = param
    @sort_by = sort_by
    @label = label
    @default = default
  end

  def self.define(sort_by_param, model_class = Notice)
    model_class::ORDERING_OPTIONS.find { |ordering| ordering.param == sort_by_param } ||
      model_class::ORDERING_OPTIONS.find { |ordering| ordering.default == true }
  end
end
