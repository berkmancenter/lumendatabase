class Category < ActiveRecord::Base
  has_many :categorizations, dependent: :destroy
  has_many :notices, through: :categorizations

  has_and_belongs_to_many :relevant_questions

  has_ancestry

  after_update { notices.each(&:touch) }

  def description_html
    Markdown.render(description.to_s)
  end

end
