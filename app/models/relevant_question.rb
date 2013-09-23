require 'validates_automatically'

class RelevantQuestion < ActiveRecord::Base
  has_and_belongs_to_many :categories
  include ValidatesAutomatically

  def answer_html
    Markdown.render(answer.to_s)
  end

end
