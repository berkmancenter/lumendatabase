require 'validates_automatically'

class RelevantQuestion < ActiveRecord::Base
  has_and_belongs_to_many :topics
  include ValidatesAutomatically

  def answer_html
    MarkdownParser.render(answer.to_s)
  end

end
