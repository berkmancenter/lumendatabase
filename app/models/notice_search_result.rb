class NoticeSearchResult < SimpleDelegator
  delegate :class, :is_a?, to: :notice

  attr_reader :_score

  def initialize(attributes = {})

    # FIXME - this dynamic class resolution may not be necessary.
    klass = attributes['class_name'].titleize.constantize
    @notice = assign_attributes(klass.new, attributes)

    @_score = attributes['_score']
    @highlight = attributes['highlight']

    super(@notice)
  end

  def with_excerpts(&block)
    Notice::HIGHLIGHTS.each do |field|
      excerpts_for(field).each(&block)
    end
  end

  private

  attr_reader :notice, :highlight

  def excerpts_for(field)
    hash_like = highlight || {}
    hash_like[field.to_s] || []
  end

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
