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

  # You can't delegate to private methods. When _result.html.erb calls
  # content_tag_for on members of a collection that may include
  # NoticeSearchResults, this invokes to_ary down the stack at
  # actionview-4.2.10/lib/action_view/helpers/record_tag_helper.rb:86. The
  # result is that warnings clutter up the output of the test suite and the
  # development rails server, even though the system works from the user's
  # perspective.
  # This code duplicates the to_ary method that Notice is ultimately using
  # (see https://github.com/rails/rails/blob/316513177cf9033d842cc176f8401d4e7c7e7c2a/activerecord/lib/active_record/core.rb#L548).
  def to_ary
    nil
  end
end
