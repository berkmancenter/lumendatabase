class Sortings

  def self.find(sort_by_param)
    instance = self.new
    instance.find(sort_by_param)
  end

  def initialize(model_class = Notice)
    @model_class = model_class
  end

  def find(sort_by_param)
    @model_class::SORTINGS.find { |sorting| sorting.key == sort_by_param } ||
      find('relevancy desc')
  end
end
