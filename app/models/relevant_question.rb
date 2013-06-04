class RelevantQuestion < ActiveRecord::Base

  def answer_html
    Markdown.render(answer.to_s)
  end

end
