class Category < ActiveRecord::Base

  has_and_belongs_to_many :notices
  has_and_belongs_to_many :relevant_questions

  has_ancestry

  validates_presence_of :name

  def description_html
    Markdown.render(description.to_s)
  end

end
