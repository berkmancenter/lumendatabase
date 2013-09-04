class Sorting
  attr_reader :key, :sort_by, :label

  def initialize(key, sort_by, label)
    @key = key
    @sort_by = sort_by
    @label = label
  end
end
