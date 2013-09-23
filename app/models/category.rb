require 'validates_automatically'

class Category < ActiveRecord::Base
  include ValidatesAutomatically

  has_many :categorizations, dependent: :destroy
  has_many :notices, through: :categorizations

  has_many :blog_entry_categorizations, dependent: :destroy
  has_many :blog_entries, through: :blog_entry_categorizations

  has_and_belongs_to_many :relevant_questions
  has_and_belongs_to_many :category_managers

  has_ancestry

  def self.ordered
    order(:name)
  end

  after_update { notices.each(&:touch) }

  def description_html
    Markdown.render(description.to_s)
  end

end
