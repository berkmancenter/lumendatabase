class BlogEntry < ActiveRecord::Base
  # TODO: is the simple :author attribute enough? Does the Association
  # really give us anything?
  belongs_to :user

  def content_html
    Markdown.render(content.to_s)
  end
end
