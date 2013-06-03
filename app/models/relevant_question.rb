class RelevantQuestion < ActiveRecord::Base

  validates_presence_of :question
  validates_presence_of :answer

  def answer_html
    Markdown.render(answer.to_s)
  end

end
