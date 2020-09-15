# frozen_string_literal: true

# This class knows how to produce the value of the :highlight key in an
# elasticsearch query hash.
class Highlighter
  def initialize(model_class)
    @model_class = model_class
    @highlight = {
      pre_tags: '<em>',
      post_tags: '</em>',
      fields: {}
    }
  end

  def value
    setup_highlight
    @highlight
  end

  private

  def setup_highlight
    @model_class::HIGHLIGHTS.each do |highlight_field|
      @highlight[:fields][highlight_field] = {
        type: 'plain',
        require_field_match: false
      }
    end
  end
end
