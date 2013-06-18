require 'validates_automatically'

class RelevantQuestion < ActiveRecord::Base
  include ValidatesAutomatically

  def answer_html
    Markdown.render(answer.to_s)
  end

end
