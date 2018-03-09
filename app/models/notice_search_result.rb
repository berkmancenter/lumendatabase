class NoticeSearchResult < SimpleDelegator
  delegate :class, :is_a?, to: :notice

  attr_reader :_score, :highlight

  def initialize(notice, attributes = {}, highlight = [])
    @notice = assign_attributes(notice, attributes)

    @_score = attributes['_score']
    @highlight = highlight.map { |highlight_single| highlight_single[1] }.flatten

    super(@notice)
  end

  private

  attr_reader :notice

  def assign_attributes(model, attributes)
    attributes.each do |key, value|
      writer = :"#{key}="

      if model.respond_to?(writer)
        model.send(writer, cast_attribute(key, value))
      end
    end

    model
  end

  def cast_attribute(key, value)
    case value
    when Array
      value.map { |v| cast_attribute(key, v) }
    when Hash
      model = key.classify.constantize.new
      assign_attributes(model, value)
    else
      value
    end
  end

end
